import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'solitude_explorer_theme.dart';
import 'package:culture_map/l10n/app_localizations.dart';

enum NavigationMode { walking, cycling, driving }

class NavigationPage extends StatefulWidget {
  final String destinationName;
  final double destinationLat;
  final double destinationLng;

  const NavigationPage({
    super.key,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();
  final FlutterTts _flutterTts = FlutterTts();
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;
  double? _distanceToDestination;
  double? _bearingToDestination;
  double _currentHeading = 0.0;
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _instructions = [];
  int _currentStepIndex = 0;
  bool _isTracking = true;
  bool _isHeadingUpMode = true;
  NavigationMode _navigationMode = NavigationMode.walking;
  bool _isLoadingRoute = false;
  double _totalDistance = 0.0;
  double _remainingDistance = 0.0; // Track remaining route distance
  Duration _estimatedTime = Duration.zero;
  Duration _remainingTime = Duration.zero; // Track remaining time
  bool _voiceEnabled = false; // Default voice OFF
  int _lastAnnouncedStep = -1;

  @override
  void initState() {
    super.initState();
    _initTts();
    WakelockPlus.enable(); // Keep screen on during navigation
    _startNavigation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _flutterTts.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _initTts() async {
    // Use system locale for TTS language
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    String ttsLanguage = 'en-US'; // Default to English

    if (locale.languageCode == 'zh') {
      ttsLanguage = 'zh-CN';
    } else if (locale.languageCode == 'es') {
      ttsLanguage = 'es-ES';
    } else if (locale.languageCode == 'fr') {
      ttsLanguage = 'fr-FR';
    } else if (locale.languageCode == 'de') {
      ttsLanguage = 'de-DE';
    } else if (locale.languageCode == 'ja') {
      ttsLanguage = 'ja-JP';
    }
    // Add more languages as needed

    await _flutterTts.setLanguage(ttsLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (_voiceEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _startNavigation() async {
    try {
      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Fetch route
      await _fetchRoute();

      // Start tracking with heading
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _currentHeading = position.heading; // Get device compass heading
          _updateNavigationInfo();
          _updateCurrentStep();

          if (_isTracking) {
            // Center on current location
            _mapController.move(_currentLocation!, _mapController.camera.zoom);

            // Rotate map to heading-up if enabled
            if (_isHeadingUpMode && _currentHeading >= 0) {
              _mapController.rotate(-_currentHeading);
            }
          }
        });
      });
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final profile = _navigationMode == NavigationMode.driving
          ? 'driving'
          : _navigationMode == NavigationMode.cycling
              ? 'cycling'
              : 'foot-walking';

      // OSRM routing API (free, open source)
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$profile/'
        '${_currentLocation!.longitude},${_currentLocation!.latitude};'
        '${widget.destinationLng},${widget.destinationLat}'
        '?overview=full&steps=true&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['routes'][0];

        // Parse route coordinates
        final coordinates = route['geometry']['coordinates'] as List;
        _routePoints = coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();

        // Parse turn-by-turn instructions
        _instructions = [];
        final legs = route['legs'] as List;
        for (var leg in legs) {
          final steps = leg['steps'] as List;
          for (var step in steps) {
            final maneuver = step['maneuver'];
            _instructions.add({
              'type': maneuver['type'],
              'modifier': maneuver['modifier'],
              'distance': step['distance'] as double,
              'location': LatLng(
                maneuver['location'][1] as double,
                maneuver['location'][0] as double,
              ),
              'icon': _getInstructionIcon(maneuver['type']),
            });
          }
        }

        // Get total distance and time
        _totalDistance = route['distance'] as double;
        _estimatedTime = Duration(seconds: (route['duration'] as double).round());

        // Initialize remaining distance and time
        _remainingDistance = _totalDistance;
        _remainingTime = _estimatedTime;

        // Announce navigation started
        if (mounted) {
          final s = AppLocalizations.of(context)!;
          final modeText = _navigationMode == NavigationMode.walking
              ? s.navWalking
              : _navigationMode == NavigationMode.cycling
                  ? s.navCycling
                  : s.navDriving;
          _speak(s.navStarting(modeText, widget.destinationName, _formatDistance(_totalDistance), _formatDuration(_estimatedTime)));
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint('Route fetch error: $e');
      // Fallback to straight line
      setState(() {
        _routePoints = [
          _currentLocation!,
          LatLng(widget.destinationLat, widget.destinationLng)
        ];
      });
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  String _translateInstruction(String type, String? modifier, BuildContext context) {
    final s = AppLocalizations.of(context)!;
    if (type == 'turn') {
      if (modifier == 'left') return s.navTurnLeft;
      if (modifier == 'right') return s.navTurnRight;
      if (modifier == 'slight left') return s.navSlightLeft;
      if (modifier == 'slight right') return s.navSlightRight;
      if (modifier == 'sharp left') return s.navSharpLeft;
      if (modifier == 'sharp right') return s.navSharpRight;
    }
    if (type == 'depart') return s.navStart;
    if (type == 'arrive') return s.navArrive;
    if (type == 'continue') return s.navContinue;
    if (type == 'roundabout') return s.navRoundabout;
    if (type == 'rotary') return s.navRotary;
    if (type == 'merge') return s.navMerge;
    if (type == 'fork') return s.navFork;
    return s.navContinueForward;
  }

  IconData _getInstructionIcon(String type) {
    switch (type) {
      case 'turn':
        return Icons.turn_right;
      case 'arrive':
        return Icons.location_on;
      case 'depart':
        return Icons.navigation;
      case 'roundabout':
        return Icons.album_outlined;
      default:
        return Icons.straight;
    }
  }

  void _updateCurrentStep() {
    if (_currentLocation == null || _instructions.isEmpty) return;

    // Calculate remaining distance along the route
    _remainingDistance = 0.0;
    for (int i = _currentStepIndex; i < _instructions.length; i++) {
      _remainingDistance += _instructions[i]['distance'] as double;
    }

    // Calculate remaining time based on navigation mode speed
    double speedMps = 1.4; // Default walking speed: 1.4 m/s (5 km/h)
    if (_navigationMode == NavigationMode.cycling) {
      speedMps = 4.2; // Cycling: 4.2 m/s (15 km/h)
    } else if (_navigationMode == NavigationMode.driving) {
      speedMps = 13.9; // Driving: 13.9 m/s (50 km/h urban)
    }
    _remainingTime = Duration(seconds: (_remainingDistance / speedMps).round());

    for (int i = 0; i < _instructions.length; i++) {
      final stepLocation = _instructions[i]['location'] as LatLng;
      final distance = const Distance().as(
        LengthUnit.Meter,
        _currentLocation!,
        stepLocation,
      );

      // Update to next step when within 30 meters and announce it
      if (distance < 30 && i > _currentStepIndex) {
        setState(() => _currentStepIndex = i);

        // Voice announcement for new step
        if (_lastAnnouncedStep != i && mounted) {
          final s = AppLocalizations.of(context)!;
          final instruction = _translateInstruction(
            _instructions[i]['type'] as String,
            _instructions[i]['modifier'] as String?,
            context,
          );
          final stepDistance = _instructions[i]['distance'] as double;
          _speak(s.navDistance(instruction, _formatDistance(stepDistance)));
          _lastAnnouncedStep = i;
        }
        break;
      }

      // Announce upcoming turn when 50-100 meters away
      if (distance > 30 && distance < 100 && i == _currentStepIndex + 1 && _lastAnnouncedStep != i && mounted) {
        final s = AppLocalizations.of(context)!;
        final instruction = _translateInstruction(
          _instructions[i]['type'] as String,
          _instructions[i]['modifier'] as String?,
          context,
        );
        _speak(s.navInMeters(distance.round(), instruction));
        _lastAnnouncedStep = i;
      }
    }

    setState(() {}); // Update UI with new remaining distance/time
  }

  void _updateNavigationInfo() {
    if (_currentLocation == null) return;

    final destination = LatLng(widget.destinationLat, widget.destinationLng);
    final previousDistance = _distanceToDestination;

    // Calculate distance
    const distance = Distance();
    _distanceToDestination = distance.as(LengthUnit.Meter, _currentLocation!, destination);

    // Calculate bearing
    _bearingToDestination = _calculateBearing(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Announce arrival
    if (_distanceToDestination! < 50 && (previousDistance == null || previousDistance >= 50) && mounted) {
      final s = AppLocalizations.of(context)!;
      _speak(s.navArrived(widget.destinationName));
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * pi / 180;
    final y = sin(dLon) * cos(lat2 * pi / 180);
    final x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos(dLon);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  String _getDirectionText(double? bearing) {
    if (bearing == null) return 'Unknown';

    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    return 'Northwest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.burgundyRed,
        foregroundColor: SolitudeExplorerTheme.stainedPaper,
        title: Text(
          widget.destinationName,
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Voice control button
          IconButton(
            icon: Icon(_voiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() => _voiceEnabled = !_voiceEnabled);
              if (_voiceEnabled) {
                final s = AppLocalizations.of(context)!;
                _speak(s.navVoiceEnabled);
              }
            },
          ),
          // Mode selector
          PopupMenuButton<NavigationMode>(
            icon: Icon(_navigationMode == NavigationMode.walking
                ? Icons.directions_walk
                : _navigationMode == NavigationMode.cycling
                    ? Icons.directions_bike
                    : Icons.directions_car),
            onSelected: (mode) {
              setState(() => _navigationMode = mode);
              _fetchRoute();

              // Announce mode change
              final s = AppLocalizations.of(context)!;
              final modeText = mode == NavigationMode.walking
                  ? s.navWalking
                  : mode == NavigationMode.cycling
                      ? s.navCycling
                      : s.navDriving;
              _speak(s.navSwitchedMode(modeText));
            },
            itemBuilder: (context) {
              final s = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                  value: NavigationMode.walking,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_walk),
                      const SizedBox(width: 8),
                      Text(s.navWalking, style: GoogleFonts.crimsonText()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: NavigationMode.cycling,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bike),
                      const SizedBox(width: 8),
                      Text(s.navCycling, style: GoogleFonts.crimsonText()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: NavigationMode.driving,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car),
                      const SizedBox(width: 8),
                      Text(s.navDriving, style: GoogleFonts.crimsonText()),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(widget.destinationLat, widget.destinationLng),
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 19.0,
              onTap: (_, __) {
                setState(() => _isTracking = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.solitude.explorer',
              ),

              // Route line
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6.0,
                      color: SolitudeExplorerTheme.burgundyRed,
                    ),
                  ],
                ),

              // Current location marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: _currentHeading * pi / 180,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.navigation, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),

              // Destination marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.destinationLat, widget.destinationLng),
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: SolitudeExplorerTheme.burgundyRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // North compass button (top left)
          Positioned(
            top: 16,
            left: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isHeadingUpMode = !_isHeadingUpMode;
                    if (!_isHeadingUpMode) {
                      _mapController.rotate(0); // Reset to north
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Transform.rotate(
                    angle: _isHeadingUpMode ? _currentHeading * pi / 180 : 0,
                    child: Icon(
                      Icons.explore,
                      size: 32,
                      color: _isHeadingUpMode
                          ? SolitudeExplorerTheme.burgundyRed
                          : SolitudeExplorerTheme.compassGold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Current turn instruction (top center)
          if (_instructions.isNotEmpty && _currentStepIndex < _instructions.length)
            Positioned(
              top: 16,
              left: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.compassGold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _instructions[_currentStepIndex]['icon'],
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translateInstruction(
                              _instructions[_currentStepIndex]['type'],
                              _instructions[_currentStepIndex]['modifier'],
                              context,
                            ),
                            style: GoogleFonts.crimsonText(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatDistance(_instructions[_currentStepIndex]['distance']),
                            style: GoogleFonts.crimsonText(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Distance and ETA panel (bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Distance
                  Column(
                    children: [
                      Icon(Icons.straighten, color: SolitudeExplorerTheme.burgundyRed, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        _formatDistance(_remainingDistance > 0 ? _remainingDistance : _distanceToDestination),
                        style: GoogleFonts.cinzel(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: SolitudeExplorerTheme.burgundyRed,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.navRemaining,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: SolitudeExplorerTheme.fadedInk,
                        ),
                      ),
                    ],
                  ),

                  // ETA
                  Column(
                    children: [
                      Icon(Icons.access_time, color: SolitudeExplorerTheme.compassGold, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_remainingTime.inSeconds > 0 ? _remainingTime : _estimatedTime),
                        style: GoogleFonts.crimsonText(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: SolitudeExplorerTheme.inkBlack,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.navEstimatedTime,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: SolitudeExplorerTheme.fadedInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoadingRoute)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Arrival notification
          if (_distanceToDestination != null && _distanceToDestination! < 50)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.compassGold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '您已到达目的地！',
                        style: GoogleFonts.crimsonText(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
