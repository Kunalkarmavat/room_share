import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:room_share/features/home/presentation/screens/room_detail_screen.dart';

class AppTransitions {
  // ─────────────────────────────────────────────
  // Shared Axis (Horizontal - default forward)
  // ─────────────────────────────────────────────
  static PageRoute<T> sharedAxis<T>({
    required Widget page,
    SharedAxisTransitionType type =
        SharedAxisTransitionType.horizontal,
    Duration duration = const Duration(milliseconds:40), required transitionType,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          child: child,
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Fade Through (for unrelated screens)
  // ─────────────────────────────────────────────
  static PageRoute<T> fadeThrough<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Scale Transition
  // ─────────────────────────────────────────────
  static PageRoute<T> scale<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }
}