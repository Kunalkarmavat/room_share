import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:room_share/features/home/data/respositories/room_repository_impl.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/usecases/get_rooms_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final roomDatasourceProvider = Provider<RoomRemoteDatasource>((ref) {
  return RoomRemoteDatasourceImpl(ref.read(supabaseProvider));
});

final roomRepositoryProvider = Provider((ref) {
  return RoomRepositoryImpl(
    ref.read(roomDatasourceProvider),
    ref.read(supabaseProvider),
  );
});

// ── Usecases ──────────────────────────────────────────────────────────────────
final getRoomsUsecaseProvider = Provider((ref) {
  return GetRoomsUsecase(ref.read(roomRepositoryProvider));
});

// ── Filter State ──────────────────────────────────────────────────────────────

// Now starts empty — shows ALL rooms from ALL cities
final roomFilterProvider = StateProvider<RoomFilter>(
  (_) => const RoomFilter(),
);

final activeTabProvider = StateProvider<String>((_) => 'all');

final searchQueryProvider = StateProvider<String>((_) => '');

// ── Selected city (shown in header, can be changed) ───────────────────────────
// Empty string means "All Cities"
final selectedCityProvider = StateProvider<String>((_) => '');

// ── Rooms list ────────────────────────────────────────────────────────────────
final roomsProvider = FutureProvider.autoDispose<List<RoomEntity>>((ref) async {
  final filter = ref.watch(roomFilterProvider);
  final query = ref.watch(searchQueryProvider);
  final tab = ref.watch(activeTabProvider);
  final city = ref.watch(selectedCityProvider);

  String? roomType;
  String? gender;

  switch (tab) {
    case 'shared':
      roomType = 'shared';
      break;
    case 'girls_only':
      gender = 'girls_only';
      break;
  }

  return ref.read(getRoomsUsecaseProvider).call(
    filter.copyWith(
      // Only pass city if user has selected one, otherwise show all
      city: city.trim().isEmpty ? null : city.trim(),
      roomType: roomType,
      genderPreference: gender,
      searchQuery: query.trim().isEmpty ? null : query.trim(),
    ),
  );
});

// ── My Posts ──────────────────────────────────────────────────────────────────
final myRoomsProvider = FutureProvider.autoDispose<List<RoomEntity>>((ref) {
  return ref.read(roomRepositoryProvider).getMyRooms();
});

// ── Single Room Detail ────────────────────────────────────────────────────────
final roomDetailProvider =
    FutureProvider.autoDispose.family<RoomEntity, String>((ref, id) {
  return ref.read(roomRepositoryProvider).getRoomById(id);
});



