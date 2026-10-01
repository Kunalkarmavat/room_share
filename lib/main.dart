import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keys live in the git-ignored `.env` file (see `.env.example`).
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY missing. '
      'Copy .env.example to .env and fill in your values.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: App()));
}
