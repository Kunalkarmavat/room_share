import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/providers/home_providers.dart';
import 'package:room_share/features/home/presentation/screens/add_post_screen.dart';
import 'package:room_share/features/home/presentation/screens/saved_screen.dart';
import 'package:room_share/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:room_share/features/home/presentation/widgets/room_card.dart';
import 'package:room_share/features/home/presentation/widgets/room_card_shimmer.dart';
import 'package:room_share/features/profile/presentation/state/profile_providers.dart' show profileProvider;
import 'package:room_share/features/profile/presentation/view/profile_screen.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        // IndexedStack keeps each tab alive — no re-fetch when switching tabs
        index: _currentIndex,
        children: [
          _buildExploreTab(),
          const SavedScreen()
        ],
      ),
    
     
    );
  }


Widget _buildProfileAvatar() {
  final profileAsync = ref.watch(profileProvider);

  return profileAsync.when(
    loading: () => Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary,
      ),
    ),
    error: (_, __) => _avatarFallback('?'),
    data: (profile) {
      // Show network avatar if available
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: profile.avatarUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _avatarFallback(
                _getInitials(profile.fullName),
              ),
              errorWidget: (_, __, ___) => _avatarFallback(
                _getInitials(profile.fullName),
              ),
            ),
          ),
        );
      }

      // Show initials if no avatar
      return _avatarFallback(_getInitials(profile.fullName));
    },
  );
}

Widget _avatarFallback(String initials) {
  return Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primaryLight,
      border: Border.all(
        color: AppColors.primary.withOpacity(0.3),
        width: 2,
      ),
    ),
    child: Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}

String _getInitials(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) return '?';
  final words = fullName.trim().split(' ');
  if (words.length == 1) return words[0][0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}


  // ── Explore Tab ───────────────────────────────────────────────────────────
  Widget _buildExploreTab() {
    final activeTab = ref.watch(activeTabProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return SafeArea(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showCityPicker(context),
                  child: Row(
                    children: [
                      Text(
                        selectedCity.isEmpty ? 'All Cities' : selectedCity,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 20, color: AppColors.textDark),
                    ],
                  ),
                ),
                const Spacer(),
              
                GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => ref.invalidate(profileProvider)),
      child: _buildProfileAvatar(),
    ),


                
              ],
            ),
          ),

          // ── Search Bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Search rooms or PGs',
                      hintStyle: const TextStyle(
                          color: AppColors.textGrey, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.textGrey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                  const SizedBox(width: 12),
                 Expanded(
                    flex: 1,
                   child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.teal.shade700, width: 1),
                      ),  
                    ),
                  color: AppColors.textDark,
                    icon: const Icon(Icons.filter_list, size: 24,
                        color: AppColors.background),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => const FilterBottomSheet(),
                    ),
                                   ),
                 ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Filter Tabs ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TabChip(
                    label: 'All Rooms', value: 'all', active: activeTab),
                const SizedBox(width: 8),
                _TabChip(
                    label: 'Shared',
                    value: 'shared',
                    active: activeTab,
                    hasArrow: true),
                const SizedBox(width: 8),
                _TabChip(
                    label: 'Girls Only',
                    value: 'girls_only',
                    active: activeTab,
                    hasArrow: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Room List ─────────────────────────────────────────────────
          Expanded(
            child: roomsAsync.when(
              loading: () => const RoomListShimmer(),
              error: (e, _) => _buildError(e.toString()),
              data: (rooms) => rooms.isEmpty
                  ? _EmptyState(
                      onPost: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddPostScreen()),
                      ).then((_) => ref.invalidate(roomsProvider)),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          ref.refresh(roomsProvider.future),
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rooms.length,
                        itemBuilder: (_, i) => RoomCard(room: rooms[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── City picker bottom sheet ──────────────────────────────────────────────
  void _showCityPicker(BuildContext context) {
    final cities = [
      'All Cities',
      'Nagpur',
      'New York',
      'Delhi',
      'Mumbai',
      'Bangalore',
      'Chennai',
      'Pune',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select City',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cities.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) {
                final city = cities[i];
                final currentCity = ref.read(selectedCityProvider);
                final isSelected = city == 'All Cities'
                    ? currentCity.isEmpty
                    : currentCity == city;

                return ListTile(
                  title: Text(
                    city,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(selectedCityProvider.notifier).state =
                        city == 'All Cities' ? '' : city;
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text('Something went wrong',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(roomsProvider),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Chip ──────────────────────────────────────────────────────────────────
class _TabChip extends ConsumerWidget {
  final String label, value, active;
  final bool hasArrow;

  const _TabChip({
    required this.label,
    required this.value,
    required this.active,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = active == value;
    return GestureDetector(
      onTap: () => ref.read(activeTabProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textDark,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: selected ? Colors.white : AppColors.textGrey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onPost;
  const _EmptyState({required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No rooms yet in this city',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later or be the first to\nhelp your fellow students!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onPost,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Post a Room'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}