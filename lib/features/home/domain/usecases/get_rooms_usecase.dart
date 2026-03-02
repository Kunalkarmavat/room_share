import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class RoomFilter {
  final String? city;
  final String? area;
  final String? roomType;
  final String? genderPreference;
  final double? minRent;
  final double? maxRent;
  final bool? hasWifi;
  final bool? hasAc;
  final bool? hasFood;
  final bool? hasLaundry;
  final String? searchQuery;

  const RoomFilter({
    this.city,
    this.area,
    this.roomType,
    this.genderPreference,
    this.minRent,
    this.maxRent,
    this.hasWifi,
    this.hasAc,
    this.hasFood,
    this.hasLaundry,
    this.searchQuery,
  });

  RoomFilter copyWith({
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
  }) {
    return RoomFilter(
      city: city ?? this.city,
      area: area ?? this.area,
      roomType: roomType ?? this.roomType,
      genderPreference: genderPreference ?? this.genderPreference,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      hasWifi: hasWifi ?? this.hasWifi,
      hasAc: hasAc ?? this.hasAc,
      hasFood: hasFood ?? this.hasFood,
      hasLaundry: hasLaundry ?? this.hasLaundry,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class GetRoomsUsecase {
  final RoomRepository _repo;
  GetRoomsUsecase(this._repo);

  Future<List<RoomEntity>> call(RoomFilter filter) {
    return _repo.getRooms(
      city: filter.city,
      area: filter.area,
      roomType: filter.roomType,
      genderPreference: filter.genderPreference,
      minRent: filter.minRent,
      maxRent: filter.maxRent,
      hasWifi: filter.hasWifi,
      hasAc: filter.hasAc,
      hasFood: filter.hasFood,
      hasLaundry: filter.hasLaundry,
      searchQuery: filter.searchQuery,
    );
  }
}