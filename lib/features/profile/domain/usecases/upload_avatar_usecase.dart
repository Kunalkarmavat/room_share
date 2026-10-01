import '../repositories/profile_repository.dart';

class UploadAvatarUsecase {
  final ProfileRepository _repo;
  UploadAvatarUsecase(this._repo);

  Future<String> call(String userId, String imagePath) =>
      _repo.uploadAvatar(userId, imagePath);
}
