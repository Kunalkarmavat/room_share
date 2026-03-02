class RoomEntity {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String city;
  final String? area;
  final double pricePerMonth;
  final double? areaSqft;
  final String? phone;
  final String roomType;
  final String genderPreference;
  final String status;
  // amenities
  final bool hasWifi;
  final bool hasAc;
  final bool hasFood;
  final bool hasLaundry;
  final bool hasSecurity;
  // badges
  final bool isAvailableNow;
  final bool studentsOnly;
  final bool noBrokerage;
  // location
  final double? latitude;
  final double? longitude;
  // media & meta
  final List<String> imageUrls;
  final double rating;
  final bool isFavorited;
  final DateTime createdAt;

  final bool isOwnerVerified;
  

  const RoomEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.city,
    this.area,
    required this.pricePerMonth,
    this.areaSqft,
    this.phone,
    required this.roomType,
    required this.genderPreference,
    required this.status,
    this.hasWifi = false,
    this.hasAc = false,
    this.hasFood = false,
    this.hasLaundry = false,
    this.hasSecurity = false,
    this.isAvailableNow = true,
    this.studentsOnly = false,
    this.noBrokerage = false,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.rating = 0,
    this.isFavorited = false,
    required this.createdAt,
    this.isOwnerVerified = false,
  });
}