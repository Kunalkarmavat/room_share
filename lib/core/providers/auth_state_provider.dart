import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.onAuthStateChange;
});