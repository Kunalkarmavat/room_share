import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

import 'package:room_share/features/home/presentation/screens/home_screen.dart';
import 'package:room_share/features/home/presentation/screens/room_detail_screen.dart';



class AppRoutes {
  static const home = '/';
  static const roomDetail = '/room/:id';

  // Helper method to build dynamic path
  static String roomDetailPath(String id) => '/room/$id';
}


final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [

    /// ─────────────────────────────────────────────
    /// HOME ROUTE
    /// ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    
  ],
);