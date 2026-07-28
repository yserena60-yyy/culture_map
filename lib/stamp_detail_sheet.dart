import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'check_in_sheet.dart';
import 'solitude_explorer_theme.dart';
import 'models.dart';

class StampDetailSheet extends StatefulWidget {
  final Stamp stamp;
  final List<StampWaypoint> waypoints;
  final Set<int> checkedInIndices;
  final dynamic supabaseService;
  final VoidCallback? onUnlockSuccess;

  const StampDetailSheet({
    super.key,
    required this.stamp,
    this.waypoints = const [],
    this.checkedInIndices = const {},
    this.supabaseService,
    this.onUnlockSuccess,
  });

  @override
  State<StampDetailSheet> createState() => _StampDetailSheetState();
}

class _StampDetailSheetState extends State<StampDetailSheet> {
  late Set<int> _checkedInIndices;
  int? _busyIndex;

  @override
  void initState() {
    super.initState();
    _checkedInIndices = {...widget.checkedInIndices};
  }

  Future<LatLng?> _resolveCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error resolving current location: $e');
      return null;
    }
  }

  Future<void> _handleCheckIn({
    required int waypointIndex,
    required String name,
    required LatLng location,
  }) async {
    setState(() => _busyIndex = waypointIndex);
    final currentLocation = await _resolveCurrentLocation();
    if (!mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckInSheet(
        stampId: widget.stamp.id!,
        placeName: name,
        targetLocation: location,
        currentLocation: currentLocation,
        waypointIndex: waypointIndex,
      ),
    );

    if (!mounted) return;
    setState(() => _busyIndex = null);
    if (result == true) {
      setState(() => _checkedInIndices = {..._checkedInIndices, waypointIndex});
      widget.onUnlockSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stamp = widget.stamp;
    final sortedWaypoints = [...widget.waypoints]
      ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    final isRoute = stamp.isRoute && sortedWaypoints.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.stainedPaperEdge,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    stamp.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                ),
                if (_checkedInIndices.length >=
                    (isRoute ? sortedWaypoints.length : 1))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.compassGoldSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SolitudeExplorerTheme.compassGold),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: SolitudeExplorerTheme.compassGold),
                        const SizedBox(width: 4),
                        Text('Unlocked',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SolitudeExplorerTheme.compassGoldDark)),
                      ],
                    ),
                  ),
              ],
            ),
            if (stamp.region.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: SolitudeExplorerTheme.fadedInk),
                  const SizedBox(width: 8),
                  Text(
                    stamp.region,
                    style: TextStyle(
                      fontSize: 14,
                      color: SolitudeExplorerTheme.fadedInk,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            if (isRoute) ..._buildRouteSteps(sortedWaypoints)
            else ..._buildSingleCheckIn(stamp),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSingleCheckIn(Stamp stamp) {
    if (stamp.lat == null || stamp.lng == null) {
      return [
        Text(
          'This place has no check-in location configured yet.',
          style: TextStyle(color: SolitudeExplorerTheme.fadedInk, fontSize: 13),
        ),
      ];
    }

    final isChecked = _checkedInIndices.contains(0);
    return [
      Text('${isChecked ? 1 : 0}/1 checked in',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: SolitudeExplorerTheme.inkBlack)),
      const SizedBox(height: 12),
      _buildCheckInRow(
        waypointIndex: 0,
        name: stamp.name,
        location: LatLng(stamp.lat!, stamp.lng!),
        isChecked: isChecked,
      ),
    ];
  }

  List<Widget> _buildRouteSteps(List<StampWaypoint> waypoints) {
    return [
      Text('${_checkedInIndices.length}/${waypoints.length} checked in',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: SolitudeExplorerTheme.inkBlack)),
      const SizedBox(height: 12),
      ...waypoints.map((w) {
        final isChecked = _checkedInIndices.contains(w.stepOrder);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCheckInRow(
            waypointIndex: w.stepOrder,
            name: w.name,
            location: LatLng(w.lat, w.lng),
            isChecked: isChecked,
            stepLabel: 'Step ${w.stepOrder + 1}',
          ),
        );
      }),
    ];
  }

  Widget _buildCheckInRow({
    required int waypointIndex,
    required String name,
    required LatLng location,
    required bool isChecked,
    String? stepLabel,
  }) {
    final isBusy = _busyIndex == waypointIndex;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.agedYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
      ),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.location_on_outlined,
            color: isChecked
                ? SolitudeExplorerTheme.compassGold
                : SolitudeExplorerTheme.fadedInk,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stepLabel != null)
                  Text(stepLabel,
                      style: TextStyle(
                          fontSize: 11, color: SolitudeExplorerTheme.fadedInk)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SolitudeExplorerTheme.inkBlack)),
              ],
            ),
          ),
          if (isChecked)
            Text('Checked in',
                style: TextStyle(
                    color: SolitudeExplorerTheme.compassGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))
          else
            ElevatedButton(
              onPressed: isBusy
                  ? null
                  : () => _handleCheckIn(
                      waypointIndex: waypointIndex, name: name, location: location),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolitudeExplorerTheme.compassGold,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Text('Check in', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}
