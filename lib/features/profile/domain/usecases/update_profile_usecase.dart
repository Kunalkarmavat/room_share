
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository _repo;
  UpdateProfileUsecase(this._repo);

  Future<void> call(ProfileEntity profile) async {
    // Business rule: name cannot be empty
    if (profile.fullName != null && profile.fullName!.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }
    // Business rule: phone must be at least 10 digits if provided
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      final digits = profile.phone!.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        throw Exception('Enter a valid phone number');
      }
    }
    return _repo.updateProfile(profile);
  }
}