// models.dart
import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final String backgroundUrl;
  final String bio; // Note: this is 'bio', not 'signature'
  final int xp;
  final int level;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.bio,
    required this.xp,
    required this.level,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      backgroundUrl: json['background_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'background_url': backgroundUrl,
      'bio': bio,
      'xp': xp,
      'level': level,
    };
  }
}

class LandmarkStats {
  final int checkinCount;
  final int ratingCount;
  final double? avgRating;
  final int storyCount;

  LandmarkStats({
    required this.checkinCount,
    required this.ratingCount,
    this.avgRating,
    required this.storyCount,
  });

  factory LandmarkStats.fromJson(Map<String, dynamic> json) {
    return LandmarkStats(
      checkinCount: json['checkin_count'] as int? ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      avgRating: json['avg_rating'] as double?,
      storyCount: json['story_count'] as int? ?? 0,
    );
  }
}

class LandmarkUserRating {
  final String placeId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  LandmarkUserRating({
    required this.placeId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory LandmarkUserRating.fromJson(Map<String, dynamic> json) {
    return LandmarkUserRating(
      placeId: json['place_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LandmarkStory {
  final String id;
  final String placeId;
  final String userId;
  final String content;
  final DateTime createdAt;

  LandmarkStory({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory LandmarkStory.fromJson(Map<String, dynamic> json) {
    return LandmarkStory(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Stamp {
  final String? id;
  final String name;
  final String region;
  final String type;
  final String imageUrl;
  final DateTime visitDate;
  final bool isCollected;
  final bool isUnlocked;
  final double angle;
  final Color color;
  final String? dateUnlocked;

  Stamp({
    this.id,
    required this.name,
    required this.region,
    required this.type,
    required this.imageUrl,
    required this.visitDate,
    this.isCollected = false,
    this.isUnlocked = false,
    this.angle = 0.0,
    this.color = const Color(0xFF6B3636),
    this.dateUnlocked,
  });

  factory Stamp.fromJson(Map<String, dynamic> json) {
    return Stamp(
      id: json['id'] as String?,
      name: json['name'] as String,
      region: json['region'] as String,
      type: json['type'] as String? ?? 'landmark',
      imageUrl: json['image_url'] as String,
      visitDate: DateTime.parse(json['visit_date'] as String),
      isCollected: json['is_collected'] as bool? ?? false,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      angle: (json['angle'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] != null
          ? Color(json['color'] as int)
          : const Color(0xFF6B3636),
      dateUnlocked: json['date_unlocked'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'region': region,
      'type': type,
      'image_url': imageUrl,
      'visit_date': visitDate.toIso8601String(),
      'is_collected': isCollected,
      'is_unlocked': isUnlocked,
      'angle': angle,
      'color': color.value,
      if (dateUnlocked != null) 'date_unlocked': dateUnlocked,
    };
  }
}
