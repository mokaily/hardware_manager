import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class ProfileModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double audioLevel; // 0.0 to 1.0

  @HiveField(3)
  final int hapticsIntensity; // 0 to 255

  @HiveField(4)
  final double brightness; // 0.0 to 1.0

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.audioLevel,
    required this.hapticsIntensity,
    required this.brightness,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating a new profile
  factory ProfileModel.create({
    required String name,
    double audioLevel = 0.5,
    int hapticsIntensity = 128,
    double brightness = 0.5,
  }) {
    final now = DateTime.now();
    return ProfileModel(
      id: const Uuid().v4(),
      name: name,
      audioLevel: audioLevel,
      hapticsIntensity: hapticsIntensity,
      brightness: brightness,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Factory constructor for default profile
  factory ProfileModel.defaultProfile() {
    return ProfileModel.create(name: 'Default');
  }

  // Copy with method for updates
  ProfileModel copyWith({
    String? id,
    String? name,
    double? audioLevel,
    int? hapticsIntensity,
    double? brightness,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      audioLevel: audioLevel ?? this.audioLevel,
      hapticsIntensity: hapticsIntensity ?? this.hapticsIntensity,
      brightness: brightness ?? this.brightness,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Duplicate profile with new ID and name
  ProfileModel duplicate({String? newName}) {
    final now = DateTime.now();
    return ProfileModel(
      id: const Uuid().v4(),
      name: newName ?? '$name (Copy)',
      audioLevel: audioLevel,
      hapticsIntensity: hapticsIntensity,
      brightness: brightness,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'audioLevel': audioLevel,
      'hapticsIntensity': hapticsIntensity,
      'brightness': brightness,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      audioLevel: (json['audioLevel'] as num).toDouble(),
      hapticsIntensity: json['hapticsIntensity'] as int,
      brightness: (json['brightness'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        audioLevel,
        hapticsIntensity,
        brightness,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, audio: $audioLevel, haptics: $hapticsIntensity, brightness: $brightness)';
  }
}
