// lib/features/profile/data/datasources/profile_remote_datasource.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<String> uploadAvatar(String userId, String imagePath);
  Future<void> signOut();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final SupabaseClient _supabase;
  ProfileRemoteDatasourceImpl(this._supabase);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    // Fetch profile row from profiles table
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    // Get email from Supabase Auth (not stored in profiles table)
    final email = _supabase.auth.currentUser?.email;

    if (data == null) {
      // Profile row doesn't exist yet — return a minimal profile
      // This can happen if the trigger didn't fire
      return ProfileModel(
        id: userId,
        email: email,
      );
    }

    return ProfileModel.fromJson(data, email: email);
  }

  @override
  Future<void> updateProfile(
      String userId, Map<String, dynamic> data) async {
    // Check if profile row exists first
    final existing = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (existing == null) {
      // Row doesn't exist — INSERT instead of UPDATE
      await _supabase.from('profiles').insert({
        'id': userId,
        ...data,
      });
    } else {
      // Row exists — UPDATE it
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String imagePath) async {
    final file = File(imagePath);
    final ext = imagePath.split('.').last.toLowerCase();
    // Path: avatars/userId/avatar.jpg
    // Using userId as folder ensures each user has their own space
    final storagePath = '$userId/avatar.$ext';

    await _supabase.storage.from('avatars').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            upsert: true, // overwrite existing avatar
            contentType: 'image/jpeg',
          ),
        );

    // Return the public URL to store in profiles.avatar_url
    return _supabase.storage
        .from('avatars')
        .getPublicUrl(storagePath);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }


  
}
