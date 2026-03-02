import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getRooms({
    String? city,
    String? area,
    String? roomType,
    String? genderPreference,
    double? minRent,
    double? maxRent,
    bool? hasWifi,
    bool? hasAc,
    bool? hasFood,
    bool? hasLaundry,
    String? searchQuery,
  });

  Future<RoomEntity> getRoomById(String id);
  Future<List<RoomEntity>> getMyRooms();
  Future<String> createRoom(RoomEntity room, List<String> imagePaths);
  Future<void> updateRoom(RoomEntity room);
  Future<void> deleteRoom(String id);
  Future<void> updateRoomStatus(String id, String status);
  Future<void> toggleFavorite(String roomId);
  Future<List<RoomEntity>> getFavorites();
}