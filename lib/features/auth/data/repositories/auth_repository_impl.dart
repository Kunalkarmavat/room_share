import 'package:room_share/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:room_share/features/auth/domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  
  final AuthRemoteDatasource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<void> signInWithGoogle() {
    return remote.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return remote.signOut();
  }
}