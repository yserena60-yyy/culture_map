import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // User Profile Methods
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
    String? backgroundUrl,
  }) async {
    final Map<String, dynamic> updates = {};
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (backgroundUrl != null) updates['background_url'] = backgroundUrl;

    if (updates.isEmpty) return;

    await _client.from('user_profiles').update(updates).eq('id', userId);
  }

  // Landmark Methods
  Future<String?> fetchPlaceIdByWikiEntity(String wikidataEntityId) async {
    try {
      final response = await _client
          .from('places')
          .select('id')
          .eq('wikidata_entity_id', wikidataEntityId)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      print('Error fetching place by wikidata: $e');
      return null;
    }
  }

  Future<String> ensurePlaceForWikiEntity({
    required String wikidataEntityId,
    required String name,
    required double lat,
    required double lng,
    required int year,
    String? wikipediaUrl,
  }) async {
    // Check if place exists
    final existing = await fetchPlaceIdByWikiEntity(wikidataEntityId);
    if (existing != null) return existing;

    // Create new place
    final response = await _client
        .from('places')
        .insert({
          'wikidata_entity_id': wikidataEntityId,
          'name': name,
          'lat': lat,
          'lng': lng,
          'year': year,
          'wikipedia_url': wikipediaUrl,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<LandmarkStats?> fetchLandmarkStats(String placeId) async {
    try {
      final response = await _client
          .from('place_stats')
          .select()
          .eq('place_id', placeId)
          .maybeSingle();

      if (response == null) {
        return LandmarkStats(
          checkinCount: 0,
          ratingCount: 0,
          avgRating: null,
          storyCount: 0,
        );
      }
      return LandmarkStats.fromJson(response);
    } catch (e) {
      print('Error fetching landmark stats: $e');
      return null;
    }
  }

  Future<bool> fetchUserCheckin(String placeId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await _client
          .from('checkins')
          .select('id')
          .eq('place_id', placeId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user checkin: $e');
      return false;
    }
  }

  Future<void> checkIn(String placeId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('checkins').insert({
      'place_id': placeId,
      'user_id': user.id,
    });
  }

  Future<LandmarkUserRating?> fetchUserRating(String placeId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('ratings')
          .select()
          .eq('place_id', placeId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return LandmarkUserRating.fromJson(response);
    } catch (e) {
      print('Error fetching user rating: $e');
      return null;
    }
  }

  Future<void> submitRating({
    required String placeId,
    required int rating,
    String? comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('ratings').upsert({
      'place_id': placeId,
      'user_id': user.id,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<LandmarkStory>> fetchStories(String placeId) async {
    try {
      final response = await _client
          .from('stories')
          .select()
          .eq('place_id', placeId)
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List).map((json) => LandmarkStory.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching stories: $e');
      return [];
    }
  }

  Future<void> submitStory({
    required String placeId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('stories').insert({
      'place_id': placeId,
      'user_id': user.id,
      'content': content,
    });
  }

  // Route management
  Future<String> createRoute({
    required String name,
    required String description,
    required List<Map<String, dynamic>> steps,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client.from('routes').insert({
      'user_id': user.id,
      'name': name,
      'description': description,
      'steps': steps,
    }).select('id').single();

    return response['id'] as String;
  }

  // Stamp management
  Future<List<Map<String, dynamic>>> fetchAllStamps() async {
    try {
      final response = await _client.from('stamps').select();
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching stamps: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserStamps() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('user_stamps')
          .select()
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching user stamps: $e');
      return [];
    }
  }

  // Check-in system (route waypoints + per-stamp checkins)
  Future<List<StampWaypoint>> fetchAllWaypoints() async {
    try {
      final response = await _client
          .from('stamp_route_waypoints')
          .select()
          .order('step_order');
      return (response as List)
          .map((json) => StampWaypoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching waypoints: $e');
      return [];
    }
  }

  Future<List<StampCheckin>> fetchUserCheckins() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('stamp_checkins')
          .select()
          .eq('user_id', user.id);
      return (response as List)
          .map((json) => StampCheckin.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user checkins: $e');
      return [];
    }
  }

  Future<void> checkInToStamp({
    required String stampId,
    int waypointIndex = 0,
    String? photoUrl,
    String? note,
    bool isBackfill = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _client.from('stamp_checkins').upsert({
      'stamp_id': stampId,
      'user_id': user.id,
      'waypoint_index': waypointIndex,
      'photo_url': photoUrl,
      'note': note,
      'is_backfill': isBackfill,
      'checked_in_at': DateTime.now().toIso8601String(),
    });
  }
}
