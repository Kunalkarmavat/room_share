// lib/features/profile/presentation/providers/profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:room_share/features/profile/data/sources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────────
final profileDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasourceImpl(ref.read(supabaseProvider));
});

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepositoryImpl(ref.read(profileDatasourceProvider));
});

// ── Usecases ───────────────────────────────────────────────────────────────────
final getProfileUsecaseProvider = Provider((ref) {
  return GetProfileUsecase(ref.read(profileRepositoryProvider));
});

final updateProfileUsecaseProvider = Provider((ref) {
  return UpdateProfileUsecase(ref.read(profileRepositoryProvider));
});

final uploadAvatarUsecaseProvider = Provider((ref) {
  return UploadAvatarUsecase(ref.read(profileRepositoryProvider));
});

final signOutUsecaseProvider = Provider((ref) {
  return SignOutUsecase(ref.read(profileRepositoryProvider));
});

// ── Current logged-in user's profile ──────────────────────────────────────────
// autoDispose: clears when profile screen is closed
// No .family needed — only ever one logged-in user at a time
final profileProvider = FutureProvider.autoDispose<ProfileEntity>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) throw Exception('User not logged in');

  return ref.read(getProfileUsecaseProvider).call(userId);
});

// ── Profile update state (tracks loading/error during save) ───────────────────
// AsyncValue<void>:
//   - AsyncData(null)  = idle or success
//   - AsyncLoading()   = saving in progress
//   - AsyncError(e)    = something went wrong
final profileUpdateStateProvider =
    StateProvider<AsyncValue<void>>((_) => const AsyncData(null));
