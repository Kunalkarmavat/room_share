import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.ownerId,
    required super.title,
    super.description,
    required super.city,
    super.area,
    required super.pricePerMonth,
    super.areaSqft,
    super.phone,
    required super.roomType,
    required super.genderPreference,
    required super.status,
    super.hasWifi,
    super.hasAc,
    super.hasFood,
    super.hasLaundry,
    super.hasSecurity,
    super.isAvailableNow,
    super.studentsOnly,
    super.noBrokerage,
    super.latitude,
    super.longitude,
    super.imageUrls,
    super.rating,
    super.isFavorited,
    super.isOwnerVerified,
    required super.createdAt,
  });

  factory RoomModel.fromJson(
    Map<String, dynamic> json, {
    List<String> imageUrls = const [],
    bool isFavorited = false,
    bool isOwnerVerified = false, 
  }) {
    return RoomModel(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      area: json['area'],
      pricePerMonth: (json['price_per_month'] as num).toDouble(),
      areaSqft: json['area_sqft'] != null
          ? (json['area_sqft'] as num).toDouble()
          : null,
      phone: json['phone'],
      roomType: json['room_type'] ?? 'single',
      genderPreference: json['gender_preference'] ?? 'any',
      status: json['status'] ?? 'active',
      hasWifi: json['has_wifi'] ?? false,
      hasAc: json['has_ac'] ?? false,
      hasFood: json['has_food'] ?? false,
      hasLaundry: json['has_laundry'] ?? false,
      hasSecurity: json['has_security'] ?? false,
      isAvailableNow: json['is_available_now'] ?? true,
      studentsOnly: json['students_only'] ?? false,
      noBrokerage: json['no_brokerage'] ?? false,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0,
      imageUrls: imageUrls,
      isFavorited: isFavorited,
      isOwnerVerified: isOwnerVerified,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'owner_id': ownerId,
        'title': title,
        'description': description,
        'city': city,
        'area': area,
        'price_per_month': pricePerMonth,
        'area_sqft': areaSqft,
        'phone': phone,
        'room_type': roomType,
        'gender_preference': genderPreference,
        'status': status,
        'has_wifi': hasWifi,
        'has_ac': hasAc,
        'has_food': hasFood,
        'has_laundry': hasLaundry,
        'has_security': hasSecurity,
        'is_available_now': isAvailableNow,
        'students_only': studentsOnly,
        'no_brokerage': noBrokerage,
        'latitude': latitude,
        'longitude': longitude,
      };
}