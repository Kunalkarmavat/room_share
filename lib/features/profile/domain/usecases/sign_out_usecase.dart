import '../repositories/profile_repository.dart';

class SignOutUsecase {
  
  final ProfileRepository _repo;
  SignOutUsecase(this._repo);

  Future<void> call() => _repo.signOut();
}
