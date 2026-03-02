import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDatasource {
  Future<List<RoomModel>> getRooms({
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
  Future<RoomModel> getRoomById(String id);
  Future<List<RoomModel>> getMyRooms();
  Future<String> createRoom(Map<String, dynamic> data, List<String> imagePaths);
  Future<void> updateRoom(String id, Map<String, dynamic> data);
  Future<void> deleteRoom(String id);
  Future<void> updateRoomStatus(String id, String status);
  Future<void> toggleFavorite(String roomId, String userId);
  Future<Set<String>> getFavoriteRoomIds(String userId);
}

class RoomRemoteDatasourceImpl implements RoomRemoteDatasource {
  final SupabaseClient _supabase;
  RoomRemoteDatasourceImpl(this._supabase);

  // ─── helper: fetch image urls for a list of room ids ─────────────────────
  Future<Map<String, List<String>>> _fetchImageUrls(
      List<String> roomIds) async {
    if (roomIds.isEmpty) return {};
    final res = await _supabase
        .from('room_images')
        .select('room_id, image_url, order_index')
        .inFilter('room_id', roomIds)
        .order('order_index');

    final map = <String, List<String>>{};
    for (final row in res as List) {
      map.putIfAbsent(row['room_id'], () => []).add(row['image_url'] as String);
    }
    return map;
  }

  // ─── helper: upload images and return public urls ─────────────────────────
  Future<List<String>> _uploadImages(String roomId, List<String> paths) async {
    final urls = <String>[];
    for (int i = 0; i < paths.length; i++) {
      final file = File(paths[i]);
      final ext = paths[i].split('.').last;
      final path = '$roomId/$i.$ext';

      await _supabase.storage
          .from('room-images')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage.from('room-images').getPublicUrl(path);
      urls.add(url);
    }
    return urls;
  }

  @override
  Future<List<RoomModel>> getRooms({
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
  }) async {
    var query = _supabase.from('rooms').select().eq('status', 'active');

    if (city != null && city.isNotEmpty) {
      query = query.ilike('city', '%$city%');
    }

    if (area != null && area.isNotEmpty) {
      query = query.ilike('area', '%$area%');
    }
    if (roomType != null) query = query.eq('room_type', roomType);
    if (genderPreference != null)
      query = query.eq('gender_preference', genderPreference);
    if (minRent != null) query = query.gte('price_per_month', minRent);
    if (maxRent != null) query = query.lte('price_per_month', maxRent);
    if (hasWifi == true) query = query.eq('has_wifi', true);
    if (hasAc == true) query = query.eq('has_ac', true);
    if (hasFood == true) query = query.eq('has_food', true);
    if (hasLaundry == true) query = query.eq('has_laundry', true);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

   final response = await query
    .select('*, profiles(is_verified)')   // ← join profiles table
    .order('created_at', ascending: false);

// ADD THIS TEMPORARILY
    print('🏠 Rooms fetched: ${(response as List).length}');
    print('🔍 Filter — city: $city, roomType: $roomType, status: active');
    for (final r in response) {
      print('  → ${r['title']} | city: ${r['city']} | status: ${r['status']}');
    }
    final rooms = response as List;

    if (rooms.isEmpty) return [];

    final ids = rooms.map((r) => r['id'] as String).toList();
    final imageMap = await _fetchImageUrls(ids);

    // get favorites for current user
    final userId = _supabase.auth.currentUser?.id;
    final favIds =
        userId != null ? await getFavoriteRoomIds(userId) : <String>{};

    return rooms.map((json) {

    // Supabase returns the joined profile as a nested object
    // json['profiles'] looks like: {"is_verified": true}
    final profile = json['profiles'] as Map<String, dynamic>?;
    final isOwnerVerified = profile?['is_verified'] as bool? ?? false;
      
      return RoomModel.fromJson(
        json,
        imageUrls: imageMap[json['id']] ?? [],
        isFavorited: favIds.contains(json['id']),
        isOwnerVerified: isOwnerVerified,   // ← ADD THIS
      );
    }).toList();
  }

  @override
  Future<RoomModel> getRoomById(String id) async {
    final res = await _supabase.from('rooms').select().eq('id', id).single();
    final imageMap = await _fetchImageUrls([id]);
    final userId = _supabase.auth.currentUser?.id;
    final favIds =
        userId != null ? await getFavoriteRoomIds(userId) : <String>{};

    return RoomModel.fromJson(
      res,
      imageUrls: imageMap[id] ?? [],
      isFavorited: favIds.contains(id),
    );
  }

  @override
  Future<List<RoomModel>> getMyRooms() async {
    final userId = _supabase.auth.currentUser!.id;
    final res = await _supabase
        .from('rooms')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    final rooms = res as List;
    if (rooms.isEmpty) return [];

    final ids = rooms.map((r) => r['id'] as String).toList();
    final imageMap = await _fetchImageUrls(ids);

    return rooms
        .map((json) =>
            RoomModel.fromJson(json, imageUrls: imageMap[json['id']] ?? []))
        .toList();
  }

  @override
  Future<String> createRoom(
      Map<String, dynamic> data, List<String> imagePaths) async {
    final res = await _supabase.from('rooms').insert(data).select().single();
    final roomId = res['id'] as String;

    if (imagePaths.isNotEmpty) {
      final urls = await _uploadImages(roomId, imagePaths);
      final imageInserts = urls
          .asMap()
          .entries
          .map((e) => {
                'room_id': roomId,
                'image_url': e.value,
                'order_index': e.key,
              })
          .toList();
      await _supabase.from('room_images').insert(imageInserts);
    }
    return roomId;
  }

  @override
  Future<void> updateRoom(String id, Map<String, dynamic> data) async {
    await _supabase.from('rooms').update(
        {...data, 'updated_at': DateTime.now().toIso8601String()}).eq('id', id);
  }

  @override
  Future<void> deleteRoom(String id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }

  @override
  Future<void> updateRoomStatus(String id, String status) async {
    await _supabase.from('rooms').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', id);
  }

  @override
  Future<void> toggleFavorite(String roomId, String userId) async {
    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('room_id', roomId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('favorites')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } else {
      await _supabase
          .from('favorites')
          .insert({'room_id': roomId, 'user_id': userId});
    }
  }

  @override
  Future<Set<String>> getFavoriteRoomIds(String userId) async {
    final res = await _supabase
        .from('favorites')
        .select('room_id')
        .eq('user_id', userId);
    return (res as List).map((f) => f['room_id'] as String).toSet();
  }
}