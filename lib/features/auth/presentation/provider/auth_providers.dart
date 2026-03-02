import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:room_share/features/auth/data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

/// DATASOURCE
final authRemoteDatasourceProvider = Provider((ref) {
  final client = ref.watch(supabaseProvider);
  return AuthRemoteDatasource(client);
});

/// REPOSITORY
final authRepositoryProvider = Provider((ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remote);
});

/// USECASES
final signInWithGoogleProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repo);
});

final signOutProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignOut(repo);
});

/// CONTROLLER
final authControllerProvider = Provider((ref) {
  return AuthController(
    ref.watch(signInWithGoogleProvider),
    ref.watch(signOutProvider),
  );
});

class AuthController {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthController(this.signInWithGoogle, this.signOut);

  Future<void> login() async {
    await signInWithGoogle();
  }

  Future<void> logout() async {
    await signOut();
  }
}