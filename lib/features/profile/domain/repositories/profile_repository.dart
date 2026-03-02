
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<String> uploadAvatar(String userId, String imagePath);
  Future<void> signOut();
}

