import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthRemoteDatasource {
  final SupabaseClient client;

  AuthRemoteDatasource(this.client);

  /// Must be added to Supabase > Authentication > URL Configuration >
  /// Redirect URLs, and match the intent-filter in AndroidManifest.xml.
  static const _redirectUrl = 'io.supabase.flutter://login-callback';

  Future<void> signInWithGoogle() async {
    debugPrint('Starting OAuth...');
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      debugPrint('OAuth triggered');
    } catch (e) {
      debugPrint('OAuth ERROR: $e');
      rethrow; // let the UI show the error instead of failing silently
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
