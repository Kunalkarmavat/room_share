import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDatasource _datasource;
  final SupabaseClient _supabase;

  RoomRepositoryImpl(this._datasource, this._supabase);

  @override
  Future<List<RoomEntity>> getRooms({
    String? city, String? area, String? roomType,
    String? genderPreference, double? minRent, double? maxRent,
    bool? hasWifi, bool? hasAc, bool? hasFood,
    bool? hasLaundry, String? searchQuery,
  }) => _datasource.getRooms(
        city: city, area: area, roomType: roomType,
        genderPreference: genderPreference, minRent: minRent,
        maxRent: maxRent, hasWifi: hasWifi, hasAc: hasAc,
        hasFood: hasFood, hasLaundry: hasLaundry, searchQuery: searchQuery,
      );

  @override
  Future<RoomEntity> getRoomById(String id) => _datasource.getRoomById(id);

  @override
  Future<List<RoomEntity>> getMyRooms() => _datasource.getMyRooms();

  @override
  Future<String> createRoom(RoomEntity room, List<String> imagePaths) {
    final model = room as RoomModel;
    return _datasource.createRoom(model.toJson(), imagePaths);
  }

  @override
  Future<void> updateRoom(RoomEntity room) {
    final model = room as RoomModel;
    return _datasource.updateRoom(room.id, model.toJson());
  }

  @override
  Future<void> deleteRoom(String id) => _datasource.deleteRoom(id);

  @override
  Future<void> updateRoomStatus(String id, String status) =>
      _datasource.updateRoomStatus(id, status);

  @override
  Future<void> toggleFavorite(String roomId) {
    final userId = _supabase.auth.currentUser!.id;
    return _datasource.toggleFavorite(roomId, userId);
  }

  @override
  Future<List<RoomEntity>> getFavorites() async {
    final userId = _supabase.auth.currentUser!.id;
    final favIds = await _datasource.getFavoriteRoomIds(userId);
    if (favIds.isEmpty) return [];
    return _datasource.getRooms(); // extend later with an inFilter query
  }
}