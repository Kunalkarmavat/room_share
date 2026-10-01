// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:room_share/features/profile/data/sources/profile_datasource.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;

  ProfileRepositoryImpl(this._datasource);

  @override
  Future<ProfileEntity> getProfile(String userId) =>
      _datasource.getProfile(userId);

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    // Cast entity to model to access toUpdateJson()
    final model = ProfileModel(
      id: profile.id,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      phone: profile.phone,
      city: profile.city,
      bio: profile.bio,
      email: profile.email,
    );
    await _datasource.updateProfile(profile.id, model.toUpdateJson());
  }

  @override
  Future<String> uploadAvatar(String userId, String imagePath) =>
      _datasource.uploadAvatar(userId, imagePath);

  @override
  Future<void> signOut() => _datasource.signOut();
}
