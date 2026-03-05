import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:room_share/core/routes/app_transitions.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/screens/add_post_screen.dart';
import 'package:room_share/features/home/presentation/screens/home_screen.dart';
import 'package:room_share/features/home/presentation/screens/saved_screen.dart';
import 'package:room_share/features/profile/presentation/view/profile_screen.dart';

// Provider for selected index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final screens = [
      HomeScreen(),
      SavedScreen(),
      AddPostScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        animationDuration: Duration(milliseconds: 400),
        backgroundColor: RoomShareColors.onPrimary,
        indicatorColor: RoomShareColors.onPrimary,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },

        // 👇 Add this
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.normal,
            );
          },
        ),

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: RoomShareColors.primary),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.heart),
            selectedIcon: Icon(Iconsax.heart5, color: RoomShareColors.primary),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box, color: RoomShareColors.primary),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: RoomShareColors.primary),
            label: 'Profile',
          ),
        ],
      ),
       body: PageTransitionSwitcher(
  duration: const Duration(milliseconds: 400),
  transitionBuilder: (child, animation, secondaryAnimation) {
    return FadeThroughTransition(
      fillColor: Colors.transparent,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  },
  child: KeyedSubtree(
    key: ValueKey<int>(selectedIndex),
    child: screens[selectedIndex],
  ),
),
    );
  }
}
