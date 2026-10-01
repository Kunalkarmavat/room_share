// lib/features/profile/domain/entities/profile_entity.dart

class ProfileEntity {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? city;
  final String? bio;
  final String? email;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.city,
    this.bio,
    this.email,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  // copyWith lets you update one field while keeping all others
  ProfileEntity copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? city,
    String? bio,
    String? email,
    bool? isVerified, 
  }) {
    return ProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
