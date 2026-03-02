import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class AuthRemoteDatasource {
  final SupabaseClient client;

  AuthRemoteDatasource(this.client);

Future<void> signInWithGoogle() async {
  try {
    print("Starting OAuth...");

    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    print("OAuth triggered");
  } catch (e) {
    print("OAuth ERROR: $e");
  }
}
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}