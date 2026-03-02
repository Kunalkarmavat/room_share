// lib/features/profile/data/models/profile_model.dart

import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.avatarUrl,
    super.phone,
    super.city,
    super.bio,
    super.email,
    super.createdAt,
    super.updatedAt,  
    super.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      email: email,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Only fields the user can UPDATE — never send id or created_at
  Map<String, dynamic> toUpdateJson() => {
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'bio': bio,
        'avatar_url': avatarUrl,
      };
}
