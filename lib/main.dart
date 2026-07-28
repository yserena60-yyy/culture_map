import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:culture_map/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'supabase_service.dart';
import 'stamp_detail_sheet.dart';
import 'check_in_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'landmark_detail_page.dart';
import 'landmark_detail_page_new.dart';
import 'landmark_preview_card.dart';
import 'solitude_explorer_theme.dart';
import 'vintage_navigation_bar.dart';
import 'offline_maps_page_new.dart';
import 'help_feedback_page_new.dart';
import 'settings_page.dart';
import 'my_drafts_page.dart';
import 'saved_places_page.dart';
import 'edit_profile_page.dart';
import 'locale_controller.dart';


// =====================================================================
// Supabase Configuration
// =====================================================================
const String supabaseUrl = 'https://wwnvrqijkmhmybcwovwn.supabase.co';
const String supabaseKey = 'sb_publishable_ZUS9lgwxC7aDxcUmI6U3Zg__zwM12x8';

// =====================================================================
// Mapbox Configuration
// =====================================================================
const String mapboxAccessToken =
    'pk.eyJ1IjoicDMwajYiLCJhIjoiY21pam44cTl0MHQ2OTNlcGxhMmRvczhneiJ9.yMGBHgUCTkCgy1oqNEGVDA';
const String mapboxStyleUrl =
    'https://api.mapbox.com/styles/v1/p30j6/cmrxpw3k700mk01qtbbqz1cmh/tiles/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  await localeController.load();

  runApp(const CultureMapApp());
}

// =====================================================================
// Timeline Anchor — historical snapshot of a landmark
// =====================================================================
class TimelineAnchor {
  final int year;
  final String label;
  final String description;
  final String? imageUrl;

  const TimelineAnchor({
    required this.year,
    required this.label,
    required this.description,
    this.imageUrl,
  });

  factory TimelineAnchor.fromJson(Map<String, dynamic> json) {
    return TimelineAnchor(
      year: (json['year'] as num).toInt(),
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'label': label,
        'description': description,
        'image_url': imageUrl,
      };
}

// =====================================================================
// Place model
// =====================================================================
class Place {
  final String id;
  final String name;
  final String category;
  final String description;
  final double lat;
  final double lng;
  final String? wikipediaUrl;
  final String? imageUrl;
  final int year;
  final List<TimelineAnchor> timelineAnchors;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.lat,
    required this.lng,
    required this.year,
    this.wikipediaUrl,
    this.imageUrl,
    this.timelineAnchors = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Heritage Site',
      description: json['description'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      year: (json['year'] as num?)?.toInt() ?? 1800,
      wikipediaUrl: json['wikipedia_url'] as String?,
      imageUrl: json['image_url'] as String?,
      timelineAnchors: (json['timeline_anchors'] as List<dynamic>? ?? [])
          .map((e) => TimelineAnchor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'lat': lat,
      'lng': lng,
      'year': year,
      'wikipedia_url': wikipediaUrl,
      'image_url': imageUrl,
      'timeline_anchors': timelineAnchors.map((a) => a.toJson()).toList(),
    };
  }
}

// =====================================================================
// WikiPlace — a landmark from Wikidata SPARQL
// =====================================================================
class WikiPlace {
  final String entityId;
  final String title;
  final String? type;
  final double lat;
  final double lng;
  final int numericYear;
  final String displayYear;
  final String? articleUrl;
  final String? imageUrl;
  final String? description;
  final int sitelinks;

  WikiPlace({
    required this.entityId,
    required this.title,
    this.type,
    required this.lat,
    required this.lng,
    required this.numericYear,
    required this.displayYear,
    this.articleUrl,
    this.imageUrl,
    this.description,
    this.sitelinks = 0,
  });
}

IconData _iconForPlaceType(String? type) {
  if (type == null) return Icons.account_balance;
  final t = type.toLowerCase();
  if (t.contains('school') || t.contains('university') || t.contains('college')) {
    return Icons.school;
  }
  if (t.contains('church') || t.contains('cathedral') || t.contains('chapel') || t.contains('basilica')) {
    return Icons.church;
  }
  if (t.contains('mosque')) return Icons.mosque;
  if (t.contains('synagogue')) return Icons.synagogue;
  if (t.contains('temple')) {
    return t.contains('hindu') ? Icons.temple_hindu : Icons.temple_buddhist;
  }
  if (t.contains('museum')) return Icons.museum;
  if (t.contains('castle')) return Icons.castle;
  if (t.contains('fort')) return Icons.fort;
  if (t.contains('palace') || t.contains('manor') || t.contains('villa')) return Icons.villa;
  if (t.contains('theatre') || t.contains('theater') || t.contains('opera')) return Icons.theaters;
  if (t.contains('library')) return Icons.local_library;
  if (t.contains('stadium') || t.contains('arena')) return Icons.stadium;
  if (t.contains('hospital')) return Icons.local_hospital;
  if (t.contains('station') || t.contains('railway')) return Icons.train;
  if (t.contains('market') || t.contains('shop') || t.contains('store')) return Icons.storefront;
  if (t.contains('park') || t.contains('garden')) return Icons.park;
  if (t.contains('bridge')) return Icons.architecture;
  if (t.contains('tower') || t.contains('lighthouse')) return Icons.location_city;
  if (t.contains('monument') || t.contains('memorial') || t.contains('statue')) return Icons.flag;
  if (t.contains('house') || t.contains('residence') || t.contains('cottage')) return Icons.house;
  if (t.contains('apartment') || t.contains('building')) return Icons.apartment;
  return Icons.account_balance;
}

// =====================================================================
// Route models
// =====================================================================
class RouteStep {
  final String title;
  final String description;
  final LatLng location;
  final String? imageUrl;

  RouteStep({
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
  });
}

class HistoricRoute {
  final String id;
  final String name;
  final String description;
  final List<RouteStep> steps;
  final Color color;

  HistoricRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.color,
  });
}

// =====================================================================
// App Widget
// =====================================================================
class CultureMapApp extends StatelessWidget {
  const CultureMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CultureMap',
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: SolitudeExplorerThemeData.themeData,
          home: const ShellPage(),
        );
      },
    );
  }
}

// =====================================================================
// Shell Page — Bottom Navigation (3 tabs)
// =====================================================================
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 1; // Start on Map tab
  List<Place> _places = [];
  final List<WikiPlace> _unlockedStamps = [];
  WikiPlace? _newlyUnlockedStamp;
  bool _showNotification = false;

  void _unlockStamp(WikiPlace stamp) {
    if (_unlockedStamps.any((s) => s.entityId == stamp.entityId)) return;
    setState(() {
      _unlockedStamps.add(stamp);
      _newlyUnlockedStamp = stamp;
      _showNotification = true;
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() => _showNotification = false);
    });
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      setState(() => _newlyUnlockedStamp = null);
    });
  }

  @override
  void initState() {
    super.initState();
    Supabase.instance.client
        .from('places')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      if (!mounted) return;
      setState(() {
        _places = data.map((json) => Place.fromJson(json)).toList();
      });
    }, onError: (error) {
      debugPrint('Supabase Stream subscription error: $error');
    });
  }

  List<Widget> get _pages => [
        PassportPageView(unlockedStamps: _unlockedStamps),
        MapPage(places: _places, onUnlockStamp: _unlockStamp),
        MePage(places: _places),
      ];

  void _openAddPlace() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPlacePage()),
    );
  }

  Widget _buildUnlockNotification(WikiPlace stamp) {
    final s = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: SolitudeExplorerTheme.inkBlack,
        border: Border.all(color: SolitudeExplorerTheme.burgundyRed, width: 1),
        boxShadow: [
          BoxShadow(
            color: SolitudeExplorerTheme.inkBlack.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: SolitudeExplorerTheme.burgundyRed, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.newStampUnlocked,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stamp.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.check_rounded, color: SolitudeExplorerTheme.compassGold, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_index],
          // Unlock notification toast
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            top: _showNotification
                ? MediaQuery.of(context).padding.top + 12
                : -120,
            left: 16,
            right: 16,
            child: _newlyUnlockedStamp != null
                ? _buildUnlockNotification(_newlyUnlockedStamp!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: null, // Removed, using custom positioned button instead
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        border: const Border(
          top: BorderSide(color: SolitudeExplorerTheme.stainedPaperEdge, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_outlined, Icons.explore,
                  AppLocalizations.of(context)!.exploreTab),
              _buildNavItem(
                  1, Icons.map_outlined, Icons.map, AppLocalizations.of(context)!.mapTab),
              _buildNavItem(2, Icons.person_outline, Icons.person,
                  AppLocalizations.of(context)!.meTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? SolitudeExplorerTheme.burgundyRed : SolitudeExplorerTheme.fadedInk,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSerifSc(
                  color: SolitudeExplorerTheme.burgundyRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Auth Bottom Sheet
// =====================================================================
class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Supabase.instance.client.auth;
      if (_isLogin) {
        await auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        if (mounted) Navigator.pop(context);
      } else {
        final res = await auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        if (res.session == null && res.user != null) {
          setState(() {
            _errorMessage =
                'Sign-up successful! Email verification required.\nIf the link does not work, disable "Confirm email" in Supabase Dashboard, then try logging in directly.';
          });
          return;
        } else {
          if (mounted) Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? 'Login' : 'Sign Up',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SolitudeExplorerTheme.inkBlack),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Text(_errorMessage!,
                style: const TextStyle(color: SolitudeExplorerTheme.burgundyRed)),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(
                labelText: 'Password', border: OutlineInputBorder()),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: SolitudeExplorerTheme.burgundyRed,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(_isLogin ? 'Login' : 'Sign Up',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            child: Text(_isLogin
                ? 'No account? Sign up'
                : 'Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Me Page — Profile with parchment styling
// =====================================================================
class MePage extends StatefulWidget {
  final List<Place> places;
  const MePage({super.key, required this.places});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  User? _user;
  bool _isLoadingStats = true;
  int _explorationMileage = 0;
  int _unlockedLandmarks = 0;
  int _completedRoutes = 0;
  int _knowledgeContributions = 0;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
    _loadStats();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() => _user = data.session?.user);
        _loadStats();
      }
    });
  }

  Future<void> _loadStats() async {
    if (_user == null) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          _explorationMileage = 0;
          _unlockedLandmarks = 0;
          _completedRoutes = 0;
          _knowledgeContributions = 0;
        });
      }
      return;
    }

    setState(() => _isLoadingStats = true);
    try {
      final userId = _user!.id;
      final client = Supabase.instance.client;

      final stampsRes =
          await client.from('user_stamps').select('id').eq('user_id', userId);
      final unlockedCount = (stampsRes as List).length;

      final reviewsRes =
          await client.from('stamp_reviews').select('id').eq('user_id', userId);
      final reviewCount = (reviewsRes as List).length;

      final routesRes =
          await client.from('routes').select('id').eq('creator_id', userId);
      final routeCount = (routesRes as List).length;

      if (mounted) {
        setState(() {
          _unlockedLandmarks = unlockedCount;
          _completedRoutes = 0;
          _knowledgeContributions = reviewCount + routeCount;
          _explorationMileage = unlockedCount * 12;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  String _getTitle(int unlocked) {
    if (unlocked >= 50) return 'Time Walker';
    if (unlocked >= 20) return 'Senior Explorer';
    if (unlocked >= 5) return 'Junior Ranger';
    return 'Novice Traveler';
  }

  void _showAuthDialog() {
    if (_user != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: SolitudeExplorerTheme.stainedPaper,
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Supabase.instance.client.auth.signOut();
              },
              child: const Text('Sign Out',
                  style: TextStyle(color: SolitudeExplorerTheme.burgundyRed)),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AuthBottomSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(gradient: SolitudeExplorerTheme.heroLinearGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: SolitudeExplorerTheme.inkBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              _buildHeaderIcon(Icons.notifications_none_rounded),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsPage(),
                                    ),
                                  );
                                },
                                child: _buildHeaderIcon(Icons.settings_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      InkWell(
                        onTap: _user != null ? () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                          // Reload profile if updated
                          if (result == true && mounted) {
                            setState(() {
                              _user = Supabase.instance.client.auth.currentUser;
                            });
                          }
                        } : _showAuthDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.6),
                                    width: 2),
                                image: _user?.userMetadata?['avatar_url'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(_user!.userMetadata!['avatar_url']),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: NetworkImage('https://picsum.photos/201'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _user != null
                                            ? (_user!.userMetadata?['display_name'] ?? _user!.email?.split('@')[0] ?? 'Explorer')
                                            : 'Not logged in',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: SolitudeExplorerTheme.inkBlack),
                                      ),
                                      if (_user != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Lv.${(_unlockedLandmarks / 5).floor() + 1}',
                                            style: const TextStyle(
                                                color: SolitudeExplorerTheme.compassGold,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _user != null
                                        ? (_user!.userMetadata?['bio']?.isNotEmpty == true
                                            ? _user!.userMetadata!['bio']
                                            : _getTitle(_unlockedLandmarks))
                                        : 'Please login to view achievements',
                                    style: TextStyle(
                                        color:
                                            SolitudeExplorerTheme.fadedInk,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: SolitudeExplorerTheme.fadedInk),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Stats card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.stainedPaper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoadingStats
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('Mileage', '$_explorationMileage',
                              'km', Icons.route_rounded),
                          _buildStatDivider(),
                          _buildProfileStat('Landmarks', '$_unlockedLandmarks',
                              '', Icons.location_on_rounded),
                          _buildStatDivider(),
                          _buildProfileStat('Routes', '$_completedRoutes', '',
                              Icons.timeline_rounded),
                          _buildStatDivider(),
                          _buildProfileStat(
                              'Contrib.',
                              '$_knowledgeContributions',
                              '',
                              Icons.edit_note_rounded),
                        ],
                      ),
              ),
            ),
          ),

          // Menu section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.stainedPaper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.edit_document,
                      'My Drafts & Contributions',
                      SolitudeExplorerTheme.burgundyRed,
                      const MyDraftsPage(),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      Icons.bookmark_rounded,
                      'Saved Places & Routes',
                      SolitudeExplorerTheme.compassGold,
                      const SavedPlacesPage(),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      Icons.download_rounded,
                      'Offline Maps',
                      SolitudeExplorerTheme.compassGold,
                      const OfflineMapsPageNew(),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      Icons.tune_rounded,
                      'Settings',
                      SolitudeExplorerTheme.fadedInk,
                      const SettingsPage(),
                    ),
                    _buildMenuDivider(),
                    _buildMenuItem(
                      context,
                      Icons.help_outline_rounded,
                      'Help & Feedback',
                      SolitudeExplorerTheme.inkBlackLight,
                      const HelpFeedbackPageNew(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.inkBlack.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: SolitudeExplorerTheme.inkBlack.withValues(alpha: 0.7), size: 20),
    );
  }

  Widget _buildStatDivider() =>
      Container(width: 1, height: 36, color: SolitudeExplorerTheme.stainedPaperEdge);

  Widget _buildMenuDivider() => Padding(
        padding: const EdgeInsets.only(left: 56),
        child: Container(height: 1, color: SolitudeExplorerTheme.stainedPaperEdge),
      );

  Widget _buildProfileStat(
      String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.7)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SolitudeExplorerTheme.inkBlack)),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 11, color: SolitudeExplorerTheme.fadedInk)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: SolitudeExplorerTheme.fadedInk)),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color iconColor,
    Widget? page,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: SolitudeExplorerTheme.fadedInk, size: 20),
      onTap: page != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              )
          : null,
    );
  }
}

// =====================================================================
// Map Page — Antique-styled map with parchment markers
// =====================================================================
class MapPage extends StatefulWidget {
  final List<Place> places;
  final Function(WikiPlace) onUnlockStamp;
  const MapPage({super.key, required this.places, required this.onUnlockStamp});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  List<WikiPlace> _wikiPlaces = [];
  List<dynamic> _searchResults = [];
  bool _loadingWiki = false;
  bool _loadingSearch = false;

  List<Stamp> _checkableStamps = [];
  List<StampWaypoint> _checkableWaypoints = [];
  Set<String> _checkedInKeys = {};

  RangeValues _yearRange = const RangeValues(-3000, 2026);
  final LatLng _initialCenter = const LatLng(41.8902, 12.4922);
  LatLng? _currentLocation;
  bool _locating = false;
  HistoricRoute? _activeRoute;
  int _currentRouteStep = 0;
  bool _mapControllerReady = false;

  // Navigation route on map
  List<LatLng> _navigationRoute = [];
  WikiPlace? _navigationDestination;
  bool _showOnlyDestination = false;

  bool _isCreatingRoute = false;
  String _newRouteName = '';
  String _newRouteDesc = '';
  Color _newRouteColor = Colors.red;
  final List<RouteStep> _newRouteSteps = [];

  final List<HistoricRoute> _predefinedRoutes = [
    HistoricRoute(
      id: 'silk_road',
      name: 'The Silk Road',
      description: 'Ancient trade route linking East and West.',
      color: Colors.deepOrange,
      steps: [
        RouteStep(title: "Xi'an", description: "Eastern starting point of the Silk Road.", location: const LatLng(34.2658, 108.9541)),
        RouteStep(title: 'Dunhuang', description: "Gateway between Central Plains and Western Regions.", location: const LatLng(40.1421, 94.6618)),
        RouteStep(title: 'Samarkand', description: "Crossroads of world cultures.", location: const LatLng(39.6542, 66.9597)),
        RouteStep(title: 'Istanbul', description: "Western gateway of the Silk Road.", location: const LatLng(41.0082, 28.9784)),
        RouteStep(title: 'Rome', description: "Western terminus of the ancient trade route.", location: const LatLng(41.9028, 12.4964)),
      ],
    ),
    HistoricRoute(
      id: 'marco_polo',
      name: "Marco Polo's Journey",
      description: "13th-century journey from Venice to the Yuan dynasty.",
      color: Colors.purple,
      steps: [
        RouteStep(title: 'Venice', description: "Starting point, 1271.", location: const LatLng(45.4408, 12.3155)),
        RouteStep(title: 'Jerusalem', description: "Through the Holy Land.", location: const LatLng(31.7683, 35.2137)),
        RouteStep(title: 'Baghdad', description: "Mesopotamian jewel.", location: const LatLng(33.3152, 44.3661)),
        RouteStep(title: 'Kashgar', description: "Oasis fortress beyond the Pamirs.", location: const LatLng(39.4677, 75.9897)),
        RouteStep(title: 'Beijing (Dadu)', description: "Yuan capital, arrived 1275.", location: const LatLng(39.9042, 116.4074)),
      ],
    ),
    HistoricRoute(
      id: 'da_vinci',
      name: "Da Vinci's Italy",
      description: "Leonardo's artistic journey across Italy and France.",
      color: Colors.teal,
      steps: [
        RouteStep(title: 'Vinci', description: "Birthplace, 1452.", location: const LatLng(43.7831, 10.9256)),
        RouteStep(title: 'Florence', description: "Cradle of the Renaissance.", location: const LatLng(43.7696, 11.2558)),
        RouteStep(title: 'Milan', description: "Created The Last Supper.", location: const LatLng(45.4642, 9.1900)),
        RouteStep(title: 'Rome', description: "Vatican research period.", location: const LatLng(41.9028, 12.4964)),
        RouteStep(title: 'Amboise', description: "Final resting place, 1519.", location: const LatLng(47.4125, 0.9828)),
      ],
    ),
  ];

  Future<void> _locateUser() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final userCenter = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() => _currentLocation = userCenter);
      _mapController.move(userCenter, 15.0);
      _searchWikidataNearby(userCenter);
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _initLocationAndSearch() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _searchWikidataNearby(_initialCenter);
    _locateUser().catchError((e) {
      debugPrint('Error getting location on start: $e');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCheckableStamps();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCheckableStamps() async {
    try {
      final results = await Future.wait([
        _supabaseService.fetchAllStamps(),
        _supabaseService.fetchAllWaypoints(),
        _supabaseService.fetchUserCheckins(),
      ]);
      final allStamps = results[0] as List<Map<String, dynamic>>;
      final allWaypoints = results[1] as List<StampWaypoint>;
      final userCheckins = results[2] as List<StampCheckin>;

      final stamps = allStamps
          .map((s) => Stamp(
                id: s['id'] as String,
                name: s['name'] as String,
                region: s['region'] as String? ?? '',
                type: s['type'] as String? ?? 'landmark',
                imageUrl: s['image_url'] as String? ?? '',
                visitDate: DateTime.now(),
                lat: (s['lat'] as num?)?.toDouble(),
                lng: (s['lng'] as num?)?.toDouble(),
              ))
          .toList();

      if (!mounted) return;
      setState(() {
        _checkableStamps = stamps;
        _checkableWaypoints = allWaypoints;
        _checkedInKeys = userCheckins
            .map((c) => '${c.stampId}:${c.waypointIndex}')
            .toSet();
      });
    } catch (e) {
      debugPrint('Error loading checkable stamps: $e');
    }
  }

  void _openCheckInFromMap({
    required String stampId,
    required String placeName,
    required int waypointIndex,
    required LatLng location,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckInSheet(
        stampId: stampId,
        placeName: placeName,
        targetLocation: location,
        currentLocation: _currentLocation,
        waypointIndex: waypointIndex,
      ),
    );
    if (result == true) {
      _loadCheckableStamps();
    }
  }

  Future<void> _searchCity(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loadingSearch = true);
    try {
      final resp = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=5'),
        headers: {if (!kIsWeb) 'User-Agent': 'culture_map_app'},
      );
      setState(() => _searchResults = jsonDecode(resp.body).take(5).toList());
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _loadingSearch = false);
    }
  }

  void _flyToCity(double lat, double lon) {
    final newCenter = LatLng(lat, lon);
    _mapController.move(newCenter, 14.0);
    setState(() {
      _searchResults = [];
      _searchCtrl.clear();
    });
    FocusScope.of(context).unfocus();
    _searchWikidataNearby(newCenter);
  }

  Future<void> _fetchRouteToPlace(WikiPlace place) async {
    if (_currentLocation == null) {
      await _locateUser();
      if (_currentLocation == null) return;
    }

    try {
      final startLat = _currentLocation!.latitude;
      final startLng = _currentLocation!.longitude;
      final endLat = place.lat;
      final endLng = place.lng;

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        _navigationRoute = coords.map((c) => LatLng(c[1], c[0])).toList();
        _navigationDestination = place;
      });

      // Zoom to show the route
      _mapController.move(
        LatLng((startLat + endLat) / 2, (startLng + endLng) / 2),
        13.0,
      );
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  void _clearRoute() {
    setState(() {
      _navigationRoute = [];
      _navigationDestination = null;
      _showOnlyDestination = false;
    });
  }

  Future<void> _searchWikidataNearby(LatLng center) async {
    setState(() => _loadingWiki = true);
    try {
      final sparqlQuery = '''
        SELECT ?place ?placeLabel ?coords ?inception ?article ?distance ?sitelinks ?image ?description ?instanceLabel WHERE {
          SERVICE wikibase:around {
            ?place wdt:P625 ?coords .
            bd:serviceParam wikibase:center "Point(${center.longitude} ${center.latitude})"^^geo:wktLiteral .
            bd:serviceParam wikibase:radius "5" .
            bd:serviceParam wikibase:distance ?distance .
          }
          ?place wdt:P571 ?inception .
          OPTIONAL { ?place wikibase:sitelinks ?sitelinks . }
          OPTIONAL { ?place wdt:P31 ?instance . }
          OPTIONAL { ?place wdt:P18 ?image . }
          OPTIONAL { ?place schema:description ?description . FILTER(LANG(?description) = "en" || LANG(?description) = "zh") }
          OPTIONAL {
            {
              ?article schema:about ?place .
              ?article schema:isPartOf <https://en.wikipedia.org/> .
            } UNION {
              ?article schema:about ?place .
              ?article schema:isPartOf <https://zh.wikipedia.org/> .
              FILTER NOT EXISTS {
                ?otherArticle schema:about ?place .
                ?otherArticle schema:isPartOf <https://en.wikipedia.org/> .
              }
            }
          }
          SERVICE wikibase:label { bd:serviceParam wikibase:language "en,zh,fr,de". }
        }
        ORDER BY ?distance
        LIMIT 150
      ''';

      final url = Uri.parse(
          'https://query.wikidata.org/sparql?query=${Uri.encodeComponent(sparqlQuery)}&format=json');

      final response = await http.get(url, headers: {
        if (!kIsWeb)
          'User-Agent': 'CultureMap/1.0 (mailto:hello@example.com)',
        'Accept': 'application/json'
      });

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final bindings = data['results']['bindings'] as List;

      // P31 (instance-of) is multi-valued, so the same place can appear in
      // multiple rows with different type labels (and duplicated article /
      // image / description values). Collect the best value per field for
      // each entity first, then dedupe rows by entity below.
      final Map<String, List<String>> typeLabelsByEntity = {};
      final Map<String, String> articleByEntity = {};
      final Map<String, String> imageByEntity = {};
      final Map<String, String> descriptionByEntity = {};
      final Map<String, String> sitelinksByEntity = {};
      for (var item in bindings) {
        final placeUrl = item['place']['value'] as String;
        final entityId = placeUrl.split('/').last;
        final label = item['instanceLabel']?['value'] as String?;
        if (label != null) {
          typeLabelsByEntity.putIfAbsent(entityId, () => []).add(label);
        }
        final article = item['article']?['value'] as String?;
        if (article != null) articleByEntity[entityId] = article;
        final image = item['image']?['value'] as String?;
        if (image != null) imageByEntity[entityId] = image;
        final description = item['description']?['value'] as String?;
        if (description != null) descriptionByEntity[entityId] = description;
        final sitelinksStr = item['sitelinks']?['value'] as String?;
        if (sitelinksStr != null) sitelinksByEntity[entityId] = sitelinksStr;
      }

      String? bestTypeLabel(String entityId) {
        final labels = typeLabelsByEntity[entityId];
        if (labels == null || labels.isEmpty) return null;
        for (final label in labels) {
          if (_iconForPlaceType(label) != Icons.account_balance) return label;
        }
        return labels.first;
      }

      final List<WikiPlace> places = [];
      final Set<String> seenEntityIds = {};
      for (var item in bindings) {
        final title = item['placeLabel']['value'];
        final placeUrl = item['place']['value'];
        final entityId = placeUrl.split('/').last;
        if (!seenEntityIds.add(entityId)) continue;
        final articleUrl = articleByEntity[entityId];

        final coordsStr = item['coords']['value'] as String;
        final match = RegExp(r'point\(\s*([^\s)]+)\s+([^\s)]+)\s*\)',
                caseSensitive: false)
            .firstMatch(coordsStr);
        if (match == null) continue;
        final lng = double.parse(match.group(1)!);
        final lat = double.parse(match.group(2)!);

        final dateStr = item['inception']['value'] as String;
        int numericYear = 0;
        String displayYear = "Unknown";

        try {
          bool isBC = dateStr.startsWith('-');
          String cleanStr = isBC ? dateStr.substring(1) : dateStr;
          int year = int.parse(cleanStr.split('-').first);
          int actualYear = isBC ? year + 1 : year;
          numericYear = isBC ? -actualYear : actualYear;
          displayYear = isBC ? '$actualYear BC' : 'AD $actualYear';
        } catch (_) {
          continue;
        }

        final sitelinksStr = sitelinksByEntity[entityId];
        final sitelinks =
            sitelinksStr != null ? int.tryParse(sitelinksStr) ?? 0 : 0;

        // Get basic Wikidata image and description
        String? imageUrl = imageByEntity[entityId];
        String? description = descriptionByEntity[entityId];

        // Fetch detailed content from Wikipedia API if article URL exists
        if (articleUrl != null) {
          try {
            final wikiContent = await _fetchWikipediaContent(articleUrl);
            if (wikiContent != null) {
              // Use Wikipedia's better image if available
              if (wikiContent['image'] != null) {
                imageUrl = wikiContent['image'];
              }
              // Use Wikipedia's extract (first few paragraphs) instead of short description
              if (wikiContent['extract'] != null && wikiContent['extract']!.isNotEmpty) {
                description = wikiContent['extract'];
              }
            }
          } catch (e) {
            debugPrint('Wikipedia fetch error for $title: $e');
          }
        }

        places.add(WikiPlace(
          entityId: entityId,
          title: title,
          type: bestTypeLabel(entityId),
          lat: lat,
          lng: lng,
          numericYear: numericYear,
          displayYear: displayYear,
          articleUrl: articleUrl,
          imageUrl: imageUrl,
          description: description,
          sitelinks: sitelinks,
        ));
      }

      if (mounted) {
        setState(() => _wikiPlaces = places);
      }
    } catch (e) {
      debugPrint('Wikidata Error: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingWiki = false);
      }
    }
  }

  /// Fetch real content from Wikipedia API
  Future<Map<String, String?>?> _fetchWikipediaContent(String articleUrl) async {
    try {
      // Extract title from Wikipedia URL
      final uri = Uri.parse(articleUrl);
      final title = uri.pathSegments.last;
      final lang = uri.host.split('.').first; // e.g., 'zh' or 'en'

      // Wikipedia API endpoint
      final apiUrl = Uri.parse(
        'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}'
      );

      final response = await http.get(apiUrl, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      return {
        'extract': data['extract'] as String?, // Real description from Wikipedia
        'image': data['thumbnail']?['source'] as String?, // Real image URL
      };
    } catch (e) {
      debugPrint('Wikipedia API error: $e');
      return null;
    }
  }

  /// Show the parchment preview card as a bottom sheet
  void _showLandmarkPreview(BuildContext context, WikiPlace wikiPlace) {
    if (_isCreatingRoute) {
      _addNewRouteStepDialog(
        LatLng(wikiPlace.lat, wikiPlace.lng),
        defaultTitle: wikiPlace.title,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: LandmarkPreviewCard(
            name: wikiPlace.title,
            category: wikiPlace.type ?? 'Landmark',
            builtYear: wikiPlace.numericYear,
            wikipediaUrl: wikiPlace.articleUrl,
            wikidataEntityId: wikiPlace.entityId,
            description: wikiPlace.description,
            imageUrl: wikiPlace.imageUrl,
            latitude: wikiPlace.lat,
            longitude: wikiPlace.lng,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandmarkDetailPageNew(
                    wikidataEntityId: wikiPlace.entityId,
                    name: wikiPlace.title,
                    category: wikiPlace.type ?? 'Heritage Site',
                    builtYear: wikiPlace.numericYear,
                    wikipediaUrl: wikiPlace.articleUrl,
                    lat: wikiPlace.lat,
                    lng: wikiPlace.lng,
                    timelineAnchors: const [],
                    currentLocation: _currentLocation,
                  ),
                ),
              );
            },
            onCommentTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandmarkDetailPageNew(
                    wikidataEntityId: wikiPlace.entityId,
                    name: wikiPlace.title,
                    category: wikiPlace.type ?? 'Heritage Site',
                    builtYear: wikiPlace.numericYear,
                    wikipediaUrl: wikiPlace.articleUrl,
                    lat: wikiPlace.lat,
                    lng: wikiPlace.lng,
                    timelineAnchors: const [],
                    currentLocation: _currentLocation,
                  ),
                ),
              );
            },
            onNavigateTap: () {
              Navigator.pop(ctx);
              _fetchRouteToPlace(wikiPlace);
            },
          ),
        ),
      ),
    );
  }

  void _showUserPlacePreview(BuildContext context, Place place) {
    if (_isCreatingRoute) {
      _addNewRouteStepDialog(
        LatLng(place.lat, place.lng),
        defaultTitle: place.name,
        defaultDesc: place.description,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: LandmarkPreviewCard(
            name: place.name,
            category: place.category ?? 'Landmark',
            builtYear: place.year,
            wikipediaUrl: place.wikipediaUrl,
            placeId: place.id,
            description: place.description,
            imageUrl: place.imageUrl,
            latitude: place.lat,
            longitude: place.lng,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandmarkDetailPageNew(
                    placeId: place.id,
                    name: place.name,
                    category: place.category ?? 'Landmark',
                    builtYear: place.year,
                    wikipediaUrl: place.wikipediaUrl,
                    lat: place.lat,
                    lng: place.lng,
                    timelineAnchors: place.timelineAnchors,
                    currentLocation: _currentLocation,
                  ),
                ),
              );
            },
            onCommentTap: () {
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }

  HistoricRoute? _parseCrowdsourcedRoute(Place place) {
    try {
      final Map<String, dynamic> data = jsonDecode(place.description);
      final int colorVal = data['color'] ?? Colors.red.toARGB32();
      final String routeDesc = data['description'] ?? '';
      final List<dynamic> stepsJson = data['steps'] ?? [];
      final List<RouteStep> steps = stepsJson
          .map((s) => RouteStep(
                title: s['title'] ?? '',
                description: s['description'] ?? '',
                location: LatLng(
                    (s['lat'] as num).toDouble(), (s['lng'] as num).toDouble()),
                imageUrl: s['imageUrl'],
              ))
          .toList();
      return HistoricRoute(
        id: 'crowd_${place.name}_${place.lat}_${place.lng}',
        name: place.name,
        description: routeDesc,
        steps: steps,
        color: Color(colorVal),
      );
    } catch (e) {
      return null;
    }
  }

  void _addNewRouteStepDialog(LatLng point,
      {String? defaultTitle, String? defaultDesc}) {
    final titleCtrl = TextEditingController(text: defaultTitle);
    final descCtrl = TextEditingController(text: defaultDesc);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: SolitudeExplorerTheme.stainedPaper,
        title: Text(AppLocalizations.of(context)!.addWaypointTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.waypointNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.waypointDescHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.waypointNameRequired)));
                return;
              }
              setState(() {
                _newRouteSteps.add(RouteStep(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  location: point,
                ));
              });
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  void _showPublishRouteDialog() {
    final nameCtrl = TextEditingController(text: _newRouteName);
    final descCtrl = TextEditingController(text: _newRouteDesc);
    Color selectedColor = _newRouteColor;
    final colorOptions = [
      Colors.red, Colors.blue, Colors.green,
      Colors.orange, Colors.purple, Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: SolitudeExplorerTheme.stainedPaper,
          title: Text(AppLocalizations.of(context)!.publishRouteTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.routeNameHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.routeDescHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLocalizations.of(context)!.chooseColor,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: colorOptions.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() => selectedColor = color);
                        setState(() => _newRouteColor = color);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.back),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.routeNameRequired)));
                  return;
                }
                Navigator.pop(ctx);
                _submitCrowdsourcedRoute(
                    nameCtrl.text.trim(), descCtrl.text.trim(), selectedColor);
              },
              style: ElevatedButton.styleFrom(backgroundColor: SolitudeExplorerTheme.burgundyRed),
              child: Text(AppLocalizations.of(context)!.publishToCloud),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCrowdsourcedRoute(
      String name, String description, Color color) async {
    final nodesJson = _newRouteSteps
        .map((step) => {
              'title': step.title,
              'description': step.description,
              'lat': step.location.latitude,
              'lng': step.location.longitude,
            })
        .toList();

    setState(() => _isCreatingRoute = false);

    try {
      final hexColor =
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      await SupabaseService().createRoute(
        name: name,
        description: description,
        steps: nodesJson,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.publishSuccess)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.publishFail(e.toString()))));
      }
    } finally {
      setState(() => _newRouteSteps.clear());
    }
  }

  Widget _buildRouteCreatorBar() {
    final s = AppLocalizations.of(context)!;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SolitudeExplorerTheme.stainedPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.edit_road, color: _newRouteColor, size: 24),
                const SizedBox(width: 8),
                Text(s.routeCreatorTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('${s.waypointCountLabel}: ${_newRouteSteps.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: SolitudeExplorerTheme.burgundyRed)),
              ],
            ),
            const SizedBox(height: 8),
            Text(s.routeCreatorHint,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isCreatingRoute = false;
                      _newRouteSteps.clear();
                    });
                  },
                  child: Text(s.cancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _newRouteSteps.isEmpty
                      ? null
                      : () => _showPublishRouteDialog(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: SolitudeExplorerTheme.burgundyRed,
                      foregroundColor: Colors.white),
                  child: Text(s.nextPublish),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteSelectorSheet() {
    final s = AppLocalizations.of(context)!;
    final crowdsourcedRoutes = widget.places
        .where((p) => p.category == 'Crowdsourced Route')
        .map((p) => _parseCrowdsourcedRoute(p))
        .whereType<HistoricRoute>()
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: SolitudeExplorerTheme.stainedPaper,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.exploreRoutes,
                    style: GoogleFonts.notoSerifSc(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SolitudeExplorerTheme.inkBlack)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            Text(s.exploreRoutesSub,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            // Create Route card
            InkWell(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isCreatingRoute = true;
                  _newRouteSteps.clear();
                  _newRouteName = '';
                  _newRouteDesc = '';
                  _newRouteColor = Colors.red;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: SolitudeExplorerTheme.burgundyRedLinearGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_road, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.createRoute,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text(s.createRouteSub,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_predefinedRoutes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(s.featuredRoutes,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SolitudeExplorerTheme.fadedInk)),
                    ),
                    ..._predefinedRoutes
                        .map((route) => _buildRouteListTile(route)),
                  ],
                  if (crowdsourcedRoutes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(s.communityRoutes,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SolitudeExplorerTheme.fadedInk)),
                    ),
                    ...crowdsourcedRoutes
                        .map((route) => _buildRouteListTile(route)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteListTile(HistoricRoute route) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.tour, color: route.color),
        title: Text(route.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${AppLocalizations.of(context)!.stopsCount(route.steps.length)} · ${route.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _activeRoute = route;
            _currentRouteStep = 0;
          });
          if (route.steps.isNotEmpty) {
            // _mapController.move(route.steps[0].location, 14.0);
          }
        },
      ),
    );
  }

  Widget _buildTourCard() {
    if (_activeRoute == null) return const SizedBox.shrink();
    final step = _activeRoute!.steps[_currentRouteStep];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _activeRoute!.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tour_rounded,
                        size: 14, color: _activeRoute!.color),
                    const SizedBox(width: 4),
                    Text(_activeRoute!.name,
                        style: TextStyle(
                            color: _activeRoute!.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeRoute = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.stainedPaperVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: SolitudeExplorerTheme.fadedInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${AppLocalizations.of(context)!.stopLabel(_currentRouteStep + 1)}${step.title}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: SolitudeExplorerTheme.inkBlack),
          ),
          const SizedBox(height: 4),
          Text(step.description,
              style: const TextStyle(
                  fontSize: 13, color: SolitudeExplorerTheme.fadedInk, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(_activeRoute!.steps.length, (i) {
                  return Container(
                    width: i == _currentRouteStep ? 20 : 8,
                    height: 4,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: i <= _currentRouteStep
                          ? _activeRoute!.color
                          : _activeRoute!.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              Row(
                children: [
                  _buildStepButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _currentRouteStep > 0
                        ? () {
                            setState(() => _currentRouteStep--);
                            _mapController.move(_activeRoute!.steps[_currentRouteStep].location, 14.0);
                          }
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _buildStepButton(
                    icon: Icons.chevron_right_rounded,
                    filled: true,
                    onTap: _currentRouteStep < _activeRoute!.steps.length - 1
                        ? () {
                            setState(() => _currentRouteStep++);
                            _mapController.move(_activeRoute!.steps[_currentRouteStep].location, 14.0);
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(
      {required IconData icon, VoidCallback? onTap, bool filled = false}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled
              ? (isEnabled
                  ? SolitudeExplorerTheme.inkBlack
                  : SolitudeExplorerTheme.inkBlack.withValues(alpha: 0.3))
              : SolitudeExplorerTheme.stainedPaperVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color: filled
                ? Colors.white
                : (isEnabled ? SolitudeExplorerTheme.inkBlack : SolitudeExplorerTheme.fadedInk)),
      ),
    );
  }

  // Convert slider position (0-1) to actual year with non-linear mapping
  double _sliderToYear(double sliderValue) {
    // Slider range: 0.0 to 1.0
    // Time periods with different scaling:
    // - Ancient (3000BC-1800AD): compressed to 0.0-0.6 (4800 years in 60% of slider)
    // - Modern (1800AD-2026AD): expanded to 0.6-1.0 (226 years in 40% of slider)

    if (sliderValue <= 0.6) {
      // Ancient period: -3000 to 1800
      return -3000 + (sliderValue / 0.6) * 4800;
    } else {
      // Modern period: 1800 to 2026
      return 1800 + ((sliderValue - 0.6) / 0.4) * 226;
    }
  }

  // Convert actual year to slider position (0-1)
  double _yearToSlider(double year) {
    if (year <= 1800) {
      // Ancient period: -3000 to 1800
      return ((year + 3000) / 4800) * 0.6;
    } else {
      // Modern period: 1800 to 2026
      return 0.6 + ((year - 1800) / 226) * 0.4;
    }
  }

  Widget _buildTimeDimensionCard() {
    final s = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 18, color: SolitudeExplorerTheme.compassGold),
                  const SizedBox(width: 10),
                  Text('Time Dimension',
                      style: GoogleFonts.crimsonText(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: SolitudeExplorerTheme.inkBlack)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(_yearRange.start < 0 ? s.formatYearIntBC(-(_yearRange.start).toInt()) : s.formatYearIntAD(_yearRange.start.toInt()))} — ${(_yearRange.end < 0 ? s.formatYearIntBC(-(_yearRange.end).toInt()) : s.formatYearIntAD(_yearRange.end.toInt()))}',
                  style: GoogleFonts.notoSerifSc(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: SolitudeExplorerTheme.compassGold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          SizedBox(
            height: 28,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: SolitudeExplorerTheme.burgundyRed,
                inactiveTrackColor: SolitudeExplorerTheme.stainedPaperVariant,
                thumbColor: SolitudeExplorerTheme.burgundyRed,
                overlayColor: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: RangeSlider(
                values: RangeValues(
                  _yearToSlider(_yearRange.start),
                  _yearToSlider(_yearRange.end),
                ),
                min: 0.0,
                max: 1.0,
                onChanged: (RangeValues sliderValues) {
                  setState(() {
                    _yearRange = RangeValues(
                      _sliderToYear(sliderValues.start).roundToDouble(),
                      _sliderToYear(sliderValues.end).roundToDouble(),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWikiMarkers = _wikiPlaces
        .where((p) {
          // Filter by year range
          if (p.numericYear < _yearRange.start || p.numericYear > _yearRange.end) {
            return false;
          }
          // If showing only destination, filter out other places
          if (_showOnlyDestination && _navigationDestination != null) {
            return p.entityId == _navigationDestination!.entityId;
          }
          return true;
        })
        .map((p) => Marker(
              point: LatLng(p.lat, p.lng),
              width: 80,
              height: 60,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => _showLandmarkPreview(context, p),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wax-seal style marker
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SolitudeExplorerTheme.burgundyRed,
                        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(_iconForPlaceType(p.type),
                          size: 14, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: SolitudeExplorerTheme.stainedPaper.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: SolitudeExplorerTheme.stainedPaperEdge.withValues(alpha: 0.5)),
                      ),
                      child: Text(p.title,
                          style: const TextStyle(
                              fontSize: 9,
                              color: SolitudeExplorerTheme.inkBlack),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                  ],
                ),
              ),
            ))
        .toList();

    final filteredUserMarkers = widget.places
        .where((p) =>
            p.category != 'Crowdsourced Route' &&
            p.year >= _yearRange.start &&
            p.year <= _yearRange.end)
        .map((p) => Marker(
              point: LatLng(p.lat, p.lng),
              width: 22,
              height: 22,
              child: GestureDetector(
                onTap: () => _showUserPlacePreview(context, p),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.burgundyRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: SolitudeExplorerTheme.stainedPaper, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 3)
                    ],
                  ),
                ),
              ),
            ))
        .toList();

    final List<Marker> checkableMarkers = [];
    for (final stamp in _checkableStamps) {
      if (stamp.isRoute) {
        final waypoints = _checkableWaypoints
            .where((w) => w.stampId == stamp.id)
            .toList()
          ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
        for (final w in waypoints) {
          final isCheckedIn =
              _checkedInKeys.contains('${stamp.id}:${w.stepOrder}');
          checkableMarkers.add(Marker(
            point: LatLng(w.lat, w.lng),
            width: 34,
            height: 34,
            child: GestureDetector(
              onTap: () => _openCheckInFromMap(
                stampId: stamp.id!,
                placeName: '${stamp.name} · ${w.name}',
                waypointIndex: w.stepOrder,
                location: LatLng(w.lat, w.lng),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCheckedIn
                      ? SolitudeExplorerTheme.compassGold
                      : SolitudeExplorerTheme.stainedPaper,
                  border: Border.all(
                      color: SolitudeExplorerTheme.compassGold, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3)
                  ],
                ),
                child: Center(
                  child: Icon(
                    isCheckedIn ? Icons.check : Icons.flag_outlined,
                    size: 16,
                    color: isCheckedIn
                        ? Colors.white
                        : SolitudeExplorerTheme.compassGold,
                  ),
                ),
              ),
            ),
          ));
        }
      } else if (stamp.lat != null && stamp.lng != null) {
        final isCheckedIn = _checkedInKeys.contains('${stamp.id}:0');
        checkableMarkers.add(Marker(
          point: LatLng(stamp.lat!, stamp.lng!),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _openCheckInFromMap(
              stampId: stamp.id!,
              placeName: stamp.name,
              waypointIndex: 0,
              location: LatLng(stamp.lat!, stamp.lng!),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCheckedIn
                    ? SolitudeExplorerTheme.compassGold
                    : SolitudeExplorerTheme.stainedPaper,
                border: Border.all(
                    color: SolitudeExplorerTheme.compassGold, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
              ),
              child: Center(
                child: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.stars_rounded,
                  size: 18,
                  color: isCheckedIn
                      ? Colors.white
                      : SolitudeExplorerTheme.compassGold,
                ),
              ),
            ),
          ),
        ));
      }
    }

    final userLocationMarker = _currentLocation != null
        ? Marker(
            point: _currentLocation!,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.compassGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          )
        : null;

    final List<Marker> routeMarkers = [];
    if (_activeRoute != null) {
      for (int i = 0; i < _activeRoute!.steps.length; i++) {
        final step = _activeRoute!.steps[i];
        final isCurrent = i == _currentRouteStep;
        routeMarkers.add(Marker(
          point: step.location,
          width: isCurrent ? 50 : 36,
          height: isCurrent ? 50 : 36,
          child: GestureDetector(
            onTap: () {
              setState(() => _currentRouteStep = i);
              _mapController.move(step.location, 14.0);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isCurrent ? _activeRoute!.color : SolitudeExplorerTheme.stainedPaper,
                shape: BoxShape.circle,
                border: Border.all(color: _activeRoute!.color, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : _activeRoute!.color,
                      fontWeight: FontWeight.bold,
                      fontSize: isCurrent ? 16 : 12,
                    )),
              ),
            ),
          ),
        ));
      }
    }

    final List<Marker> draftRouteMarkers = [];
    if (_isCreatingRoute) {
      for (int i = 0; i < _newRouteSteps.length; i++) {
        final step = _newRouteSteps[i];
        draftRouteMarkers.add(Marker(
          point: step.location,
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: _newRouteColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4)
              ],
            ),
            child: Center(
              child: Text('${i + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
        ));
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              if (_isCreatingRoute) _addNewRouteStepDialog(point);
            },
            onMapReady: () {
              setState(() => _mapControllerReady = true);
              _initLocationAndSearch();
            },
          ),
          children: [
            // Mapbox vintage/outdoors style
            TileLayer(
              urlTemplate: mapboxStyleUrl,
              userAgentPackageName: 'com.example.culture_map',
              maxZoom: 22,
              tileSize: 512,
              zoomOffset: -1,
            ),
            // Route overlays
            if (_activeRoute != null)
              PolylineLayer<Object>(
                polylines: [
                  Polyline(
                    points:
                        _activeRoute!.steps.map((s) => s.location).toList(),
                    color: _activeRoute!.color,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            // Navigation route overlay
            if (_navigationRoute.isNotEmpty)
              PolylineLayer<Object>(
                polylines: [
                  Polyline(
                    points: _navigationRoute,
                    color: SolitudeExplorerTheme.compassGold,
                    strokeWidth: 5.0,
                    borderStrokeWidth: 2.0,
                    borderColor: SolitudeExplorerTheme.inkBlack,
                  ),
                ],
              ),
            if (_isCreatingRoute && _newRouteSteps.isNotEmpty)
              PolylineLayer<Object>(
                polylines: [
                  Polyline(
                    points:
                        _newRouteSteps.map((s) => s.location).toList(),
                    color: _newRouteColor,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                ...filteredWikiMarkers,
                ...filteredUserMarkers,
                ...checkableMarkers,
                if (userLocationMarker != null) userLocationMarker,
                ...routeMarkers,
                ...draftRouteMarkers,
              ],
            ),
          ],
        ),

        // Route selector button
        Positioned(
          top: 80,
          left: 12,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SolitudeExplorerTheme.stainedPaper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.alt_route_rounded,
                  size: 20, color: SolitudeExplorerTheme.inkBlack),
              onPressed: _showRouteSelectorSheet,
            ),
          ),
        ),

        // Search bar
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            children: [
              if (_isCreatingRoute) ...[
                _buildRouteCreatorBar(),
                const SizedBox(height: 8),
              ],
              Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.stainedPaper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12)
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchCity,
                    decoration: InputDecoration(
                      hintText: 'Search places...',
                      hintStyle: const TextStyle(
                          color: SolitudeExplorerTheme.fadedInk, fontSize: 15),
                      prefixIcon: const Icon(Icons.search,
                          color: SolitudeExplorerTheme.compassGold, size: 22),
                      suffixIcon: _loadingSearch
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: SolitudeExplorerTheme.burgundyRed)))
                          : (_searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 20, color: SolitudeExplorerTheme.fadedInk),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchResults = []);
                                  })
                              : null),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: SolitudeExplorerTheme.stainedPaper,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.stainedPaper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ]),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _searchResults[i];
                      return ListTile(
                        leading: const Icon(Icons.location_city,
                            color: SolitudeExplorerTheme.fadedInk),
                        title: Text(r['display_name'],
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _flyToCity(
                            double.parse(r['lat']), double.parse(r['lon'])),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Right side control buttons
        Positioned(
          top: 80,
          right: 16,
          child: Column(
            children: [
              // My location button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.stainedPaper,
                  shape: BoxShape.circle,
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
                  ],
                ),
                child: IconButton(
                  onPressed: _locating ? null : _locateUser,
                  icon: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: SolitudeExplorerTheme.compassGold))
                      : const Icon(Icons.my_location,
                          size: 22, color: SolitudeExplorerTheme.inkBlack),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        // Add place button (bottom right, circular)
        Positioned(
          bottom: 200,
          right: 16,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SolitudeExplorerTheme.burgundyRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), blurRadius: 12)
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Add place functionality - can be connected later
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPlacePage()),
                );
              },
              icon: const Icon(Icons.add,
                  size: 28, color: Colors.white),
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // Search area button
        Positioned(
          bottom: 143,
          right: 16,
          child: GestureDetector(
            onTap: _loadingWiki
                ? null
                : () => _searchWikidataNearby(_mapController.camera.center),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.radar,
                    size: 18,
                    color: _loadingWiki
                        ? SolitudeExplorerTheme.fadedInk
                        : SolitudeExplorerTheme.inkBlack,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search Area',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _loadingWiki
                          ? SolitudeExplorerTheme.fadedInk
                          : SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                  if (_loadingWiki) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: SolitudeExplorerTheme.burgundyRed),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Navigation controls (show when route is active)
        if (_navigationRoute.isNotEmpty) ...[
          // Clear route button
          Positioned(
            bottom: 264,
            right: 16,
            child: GestureDetector(
              onTap: _clearRoute,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.burgundyRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8)
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Toggle all places / destination only
          Positioned(
            bottom: 324,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showOnlyDestination = !_showOnlyDestination;
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _showOnlyDestination
                      ? SolitudeExplorerTheme.compassGold
                      : SolitudeExplorerTheme.stainedPaper,
                  shape: BoxShape.circle,
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8)
                  ],
                ),
                child: Icon(
                  _showOnlyDestination ? Icons.location_on : Icons.map,
                  size: 24,
                  color: _showOnlyDestination
                      ? Colors.white
                      : SolitudeExplorerTheme.inkBlack,
                ),
              ),
            ),
          ),
        ],

        // Bottom card (time slider or route tour)
        Positioned(
          bottom: 24,
          left: 12,
          right: 12,
          child: _isCreatingRoute
              ? const SizedBox.shrink()
              : (_activeRoute != null
                  ? _buildTourCard()
                  : _buildTimeDimensionCard()),
        ),
      ],
    );
  }
}

// =====================================================================
// Place Detail Page (simple view)
// =====================================================================
class PlaceDetailPage extends StatelessWidget {
  final Place place;
  const PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(place.category)),
                Chip(label: Text('Year: ${place.year}')),
                Chip(
                    label: Text(
                        '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Historical Archives',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 8),
            Text(place.description,
                style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Add Place Page
// =====================================================================
class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});
  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _wikiUrl = TextEditingController();
  String _category = 'Heritage Site';
  double _year = 1800;
  LatLng? _picked;
  bool _isUploading = false;

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => PickLocationPage(initial: _picked)),
    );
    if (result != null) setState(() => _picked = result);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map.')));
      return;
    }

    setState(() => _isUploading = true);
    final newPlace = Place(
      id: '',
      name: _name.text.trim(),
      category: _category,
      description: _desc.text.trim(),
      lat: _picked!.latitude,
      lng: _picked!.longitude,
      year: _year.toInt(),
      wikipediaUrl: _wikiUrl.text.trim(),
    );

    try {
      await Supabase.instance.client.from('places').insert(newPlace.toJson());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully uploaded!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contribute Coordinate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Place Name',
                      border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: const [
                  DropdownMenuItem(
                      value: 'Heritage Site', child: Text('Heritage Site')),
                  DropdownMenuItem(value: 'Museum', child: Text('Museum')),
                  DropdownMenuItem(
                      value: 'Religious',
                      child: Text('Religious Monument')),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Year Built / Active',
                    border: OutlineInputBorder()),
                child: Column(
                  children: [
                    Text(
                        (_year < 0
                            ? AppLocalizations.of(context)!
                                .formatYearIntBC(-_year.toInt())
                            : AppLocalizations.of(context)!
                                .formatYearIntAD(_year.toInt())),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: SolitudeExplorerTheme.burgundyRed)),
                    Slider(
                      value: _year,
                      min: -3000,
                      max: 2026,
                      label: (_year < 0
                          ? AppLocalizations.of(context)!
                              .formatYearIntBC(-_year.toInt())
                          : AppLocalizations.of(context)!
                              .formatYearIntAD(_year.toInt())),
                      onChanged: (v) =>
                          setState(() => _year = v.roundToDouble()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Archive Records / Story',
                      border: OutlineInputBorder())),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Pick location on map')),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _submit,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload),
                label: Text(
                    _isUploading ? 'Uploading...' : 'Submit to Database'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: SolitudeExplorerTheme.burgundyRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Pick Location Page
// =====================================================================
class PickLocationPage extends StatefulWidget {
  final LatLng? initial;
  const PickLocationPage({super.key, this.initial});
  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  LatLng? _selected;
  bool _loading = false;
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _locateUserOnInit() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final userCenter = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      // _mapController.move(userCenter, 16.0);
      setState(() => _selected = userCenter);
    } catch (e) {
      debugPrint('Error getting initial location on picker: $e');
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=5'),
        headers: {if (!kIsWeb) 'User-Agent': 'culture_map_app'},
      );
      setState(() => _results = jsonDecode(resp.body).take(5).toList());
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Location'),
        actions: [
          TextButton(
              onPressed:
                  _selected == null ? null : () => Navigator.pop(context, _selected),
              child: Text('Done',
                  style: TextStyle(
                      color: _selected == null ? Colors.grey : SolitudeExplorerTheme.burgundyRed,
                      fontWeight: FontWeight.bold)))
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected ?? const LatLng(52.3702, 4.8952),
              initialZoom: _selected == null ? 4.0 : 16.0,
              onTap: (_, point) => setState(() => _selected = point),
              onMapReady: () {
                if (_selected == null) _locateUserOnInit();
              },
            ),
            children: [
              TileLayer(
                  urlTemplate: mapboxStyleUrl,
                  userAgentPackageName: 'com.example.culture_map',
                  maxZoom: 22,
                  tileSize: 512,
                  zoomOffset: -1),
              if (_selected != null)
                MarkerLayer(markers: [
                  Marker(
                      point: _selected!,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_on,
                          size: 40, color: SolitudeExplorerTheme.burgundyRed))
                ]),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: 'Search locations...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _results = []);
                              }),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: SolitudeExplorerTheme.stainedPaper,
                    ),
                  ),
                ),
                if (_results.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    color: SolitudeExplorerTheme.stainedPaper,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (c, i) => ListTile(
                        title:
                            Text(_results[i]['display_name'], maxLines: 2),
                        onTap: () {
                          final p = LatLng(
                              double.parse(_results[i]['lat']),
                              double.parse(_results[i]['lon']));
                          // _mapController.move(p, 16);
                          setState(() {
                            _selected = p;
                            _results = [];
                          });
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SplitCompareView, ScrollDiaryView, PassportPageView
// =============================================================================
class SplitCompareView extends StatefulWidget {
  final String modernUrl;
  final String ancientUrl;
  final String modernLabel;
  final String ancientLabel;

  const SplitCompareView({
    super.key,
    required this.modernUrl,
    required this.ancientUrl,
    this.modernLabel = 'Modern',
    this.ancientLabel = 'Ancient Era',
  });

  @override
  State<SplitCompareView> createState() => _SplitCompareViewState();
}

class _SplitCompareViewState extends State<SplitCompareView> {
  double _dividerX = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dividerX =
                      (details.localPosition.dx / width).clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.modernUrl.isNotEmpty
                        ? Image.network(widget.modernUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                  Positioned.fill(
                    child: ClipPath(
                      clipper: SplitClipper(_dividerX),
                      child: widget.ancientUrl.isNotEmpty
                          ? Image.network(widget.ancientUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder())
                          : _placeholder(),
                    ),
                  ),
                  Positioned(
                    left: _dividerX * width - 15,
                    top: 0,
                    bottom: 0,
                    width: 30,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 2, height: height, color: Colors.white),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: SolitudeExplorerTheme.burgundyRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 4)
                              ],
                            ),
                            child: const Icon(Icons.unfold_more,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      left: 8,
                      top: 8,
                      child: _labelChip(widget.modernLabel, Colors.black54)),
                  Positioned(
                      right: 8,
                      top: 8,
                      child:
                          _labelChip(widget.ancientLabel, SolitudeExplorerTheme.burgundyRedDark)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _labelChip(String text, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _placeholder() => Container(
        color: SolitudeExplorerTheme.stainedPaperDark,
        child: const Center(
            child: Icon(Icons.account_balance, size: 48, color: SolitudeExplorerTheme.fadedInk)),
      );
}

class SplitClipper extends CustomClipper<Path> {
  final double dividerX;
  SplitClipper(this.dividerX);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * dividerX, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * dividerX, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SplitClipper oldClipper) =>
      oldClipper.dividerX != dividerX;
}

class ScrollDiaryView extends StatelessWidget {
  final String title;
  final String text;
  final String displayYear;
  final bool isFetching;

  const ScrollDiaryView({
    super.key,
    required this.title,
    required this.text,
    required this.displayYear,
    required this.isFetching,
  });

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: SolitudeExplorerTheme.stainedPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
        ),
        child: const Center(child: CircularProgressIndicator(color: SolitudeExplorerTheme.burgundyRed)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu_book, color: SolitudeExplorerTheme.inkBlack, size: 18),
              Text(displayYear,
                  style: const TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          Divider(color: SolitudeExplorerTheme.stainedPaperEdge, height: 16),
          Text(text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: SolitudeExplorerTheme.inkBlack,
                fontStyle: FontStyle.italic,
              )),
        ],
      ),
    );
  }
}

// =====================================================================
// Passport Page View (Stamp collection with parchment styling)
// =====================================================================
class PassportPageView extends StatefulWidget {
  final List<WikiPlace> unlockedStamps;
  const PassportPageView({super.key, required this.unlockedStamps});

  @override
  State<PassportPageView> createState() => _PassportPageViewState();
}

class _PassportPageViewState extends State<PassportPageView> {
  final PageController _pageController = PageController();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = true;
  List<Stamp> _europeStamps = [];
  List<Stamp> _globalStamps = [];
  List<Stamp> _routeStamps = [];
  List<StampWaypoint> _allWaypoints = [];
  List<StampCheckin> _userCheckins = [];

  @override
  void initState() {
    super.initState();
    _loadStamps();
  }

  Future<void> _loadStamps() async {
    try {
      final results = await Future.wait([
        _supabaseService.fetchAllStamps(),
        _supabaseService.fetchAllWaypoints(),
        _supabaseService.fetchUserCheckins(),
      ]);
      final allStamps = results[0] as List<Map<String, dynamic>>;
      final allWaypoints = results[1] as List<StampWaypoint>;
      final userCheckins = results[2] as List<StampCheckin>;

      final waypointsByStamp = <String, List<StampWaypoint>>{};
      for (final w in allWaypoints) {
        waypointsByStamp.putIfAbsent(w.stampId, () => []).add(w);
      }
      final checkinsByStamp = <String, List<StampCheckin>>{};
      for (final c in userCheckins) {
        checkinsByStamp.putIfAbsent(c.stampId, () => []).add(c);
      }

      Stamp mapStamp(Map<String, dynamic> dbStamp) {
        final stampId = dbStamp['id'] as String;
        final waypoints = waypointsByStamp[stampId] ?? const [];
        final totalSteps = waypoints.isNotEmpty ? waypoints.length : 1;
        final stampCheckins = checkinsByStamp[stampId] ?? const [];
        final checkedInIndices =
            stampCheckins.map((c) => c.waypointIndex).toSet();
        final checkedInSteps =
            checkedInIndices.where((i) => i < totalSteps).length;
        final isUnlocked = checkedInSteps >= totalSteps;

        String? dateUnlocked;
        if (isUnlocked && stampCheckins.isNotEmpty) {
          final latest = stampCheckins
              .map((c) => c.checkedInAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          dateUnlocked =
              "${latest.year}.${latest.month.toString().padLeft(2, '0')}.${latest.day.toString().padLeft(2, '0')}";
        }

        return Stamp(
          id: stampId,
          name: dbStamp['name'] as String,
          region: dbStamp['region'] as String? ?? '',
          type: dbStamp['type'] as String? ?? 'landmark',
          imageUrl: dbStamp['image_url'] as String? ?? '',
          visitDate: DateTime.now(),
          isCollected: false,
          color: Color(int.tryParse((dbStamp['color_hex'] as String? ?? '#6B3636').replaceFirst('#', '0xFF')) ?? 0xFF6B3636),
          isUnlocked: isUnlocked,
          dateUnlocked: dateUnlocked,
          angle: 0,
          lat: (dbStamp['lat'] as num?)?.toDouble(),
          lng: (dbStamp['lng'] as num?)?.toDouble(),
          totalSteps: totalSteps,
          checkedInSteps: checkedInSteps,
        );
      }

      setState(() {
        _europeStamps =
            allStamps.where((s) => (s['category'] as String?) == 'europe').map(mapStamp).toList();
        _globalStamps =
            allStamps.where((s) => (s['category'] as String?) == 'global').map(mapStamp).toList();
        _routeStamps =
            allStamps.where((s) => (s['category'] as String?) == 'route').map(mapStamp).toList();
        _allWaypoints = allWaypoints;
        _userCheckins = userCheckins;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stamps: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.stainedPaper,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.passportTitle ?? 'Explorer Hall',
          style: GoogleFonts.notoSerifSc(
              color: SolitudeExplorerTheme.inkBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: SolitudeExplorerTheme.inkBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabIndicator(0, 'Europe'),
                _buildTabIndicator(1, 'World'),
                _buildTabIndicator(2, 'Routes'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: SolitudeExplorerTheme.burgundyRed))
                : PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildGridPage(_europeStamps),
                      _buildGridPage(_globalStamps),
                      _buildGridPage(_routeStamps),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabIndicator(int index, String text) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page =
            _pageController.hasClients ? (_pageController.page ?? 0) : 0;
        bool isActive = (page.round() == index);
        return GestureDetector(
          onTap: () => _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? SolitudeExplorerTheme.burgundyRed : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isActive
                  ? null
                  : Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : SolitudeExplorerTheme.fadedInk,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridPage(List<Stamp> stamps) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 110,
          mainAxisSpacing: 32,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: stamps.length,
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(width: 80, child: _buildCircularStamp(stamps[index])),
          );
        },
      ),
    );
  }

  void _showStampDetails(BuildContext context, Stamp stamp) {
    final waypoints =
        _allWaypoints.where((w) => w.stampId == stamp.id).toList();
    final checkedInIndices = _userCheckins
        .where((c) => c.stampId == stamp.id)
        .map((c) => c.waypointIndex)
        .toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StampDetailSheet(
        stamp: stamp,
        waypoints: waypoints,
        checkedInIndices: checkedInIndices,
        supabaseService: _supabaseService,
        onUnlockSuccess: () => _loadStamps(),
      ),
    );
  }

  Widget _buildCircularStamp(Stamp stamp) {
    if (!stamp.isUnlocked) {
      final hasProgress = stamp.isRoute && stamp.checkedInSteps > 0;
      return GestureDetector(
        onTap: () => _showStampDetails(context, stamp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SolitudeExplorerTheme.stainedPaperDark,
                    border: Border.all(
                        color: hasProgress
                            ? SolitudeExplorerTheme.compassGold
                            : SolitudeExplorerTheme.stainedPaperEdge,
                        width: hasProgress ? 2 : 1),
                  ),
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: CachedNetworkImage(
                        imageUrl: stamp.imageUrl,
                        httpHeaders: const {
                          'User-Agent': 'CultureMapApp/1.0 (contact@culturemap.com)'
                        },
                        memCacheWidth: 150,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(Icons.lock_outline,
                        color: Colors.white.withValues(alpha: 0.9), size: 28),
                  ),
                ),
                if (hasProgress)
                  Positioned(
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SolitudeExplorerTheme.stainedPaper,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SolitudeExplorerTheme.compassGold, width: 1),
                      ),
                      child: Text(
                        '${stamp.checkedInSteps}/${stamp.totalSteps}',
                        style: TextStyle(
                            color: SolitudeExplorerTheme.compassGoldDark,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(stamp.name,
                style: TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showStampDetails(context, stamp),
      child: Transform.rotate(
        angle: stamp.angle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: stamp.color.withValues(alpha: 0.3), width: 3),
                  ),
                ),
                SizedBox(
                  width: 66,
                  height: 66,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: stamp.imageUrl,
                      httpHeaders: const {
                        'User-Agent': 'CultureMapApp/1.0 (contact@culturemap.com)'
                      },
                      memCacheWidth: 150,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          color: stamp.color.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.stainedPaper,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: stamp.color, width: 1),
                    ),
                    child: Text(stamp.dateUnlocked ?? '',
                        style: TextStyle(
                            color: stamp.color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(stamp.name,
                style: const TextStyle(
                    color: SolitudeExplorerTheme.inkBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
