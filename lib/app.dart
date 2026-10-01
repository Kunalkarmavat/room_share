import 'package:flutter/material.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/auth/presentation/screen/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomShare',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
