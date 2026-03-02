import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository _repo;
  GetProfileUsecase(this._repo);

  Future<ProfileEntity> call(String userId) => _repo.getProfile(userId);
}

