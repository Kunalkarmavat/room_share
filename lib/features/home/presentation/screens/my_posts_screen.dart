import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/features/home/domain/entities/room_entity.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/providers/home_providers.dart';
import 'add_post_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PHASE D — My Posts Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Posts',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 26),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPostScreen()),
              ).then((_) => ref.invalidate(myRoomsProvider)),
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Rented'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PostList(status: 'active'),
            _PostList(status: 'rented'),
          ],
        ),
      ),
    );
  }
}

// ── Posts list filtered by status ─────────────────────────────────────────────
class _PostList extends ConsumerWidget {
  final String status;
  const _PostList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRoomsAsync = ref.watch(myRoomsProvider);

    return myRoomsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rooms) {
        final filtered =
            rooms.where((r) => r.status == status).toList();

        if (filtered.isEmpty) {
          return _EmptyPostsState(
            status: status,
            onAddPost: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPostScreen()),
            ).then((_) => ref.invalidate(myRoomsProvider)),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(myRoomsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _MyPostCard(
              room: filtered[i],
              onDeleted: () => ref.invalidate(myRoomsProvider),
              onStatusChanged: () => ref.invalidate(myRoomsProvider),
            ),
          ),
        );
      },
    );
  }
}

// ── My Post Card ──────────────────────────────────────────────────────────────
class _MyPostCard extends ConsumerWidget {
  final RoomEntity room;
  final VoidCallback onDeleted;
  final VoidCallback onStatusChanged;

  const _MyPostCard({
    required this.room,
    required this.onDeleted,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = room.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Image + Status badge ─────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: room.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: room.imageUrls.first,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            height: 160,
                            color: AppColors.primaryLight),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'RENTED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Details ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${room.pricePerMonth.toInt()}/month • ${room.area ?? room.city}',
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // ── Action Buttons ─────────────────────────────────────────
                Row(
                  children: [
                    if (isActive) ...[
                      Expanded(
                        child: _actionButton(
                          label: 'Edit Post',
                          icon: Icons.edit_outlined,
                          color: AppColors.primary,
                          outlined: true,
                          onTap: () {
                            // TODO: Navigate to edit screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Edit coming soon!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          label: 'Mark Rented',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.grey.shade600,
                          outlined: true,
                          onTap: () => _confirmStatusChange(
                              context, ref, 'rented'),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: _actionButton(
                          label: 'Re-list',
                          icon: Icons.refresh_rounded,
                          color: AppColors.primary,
                          outlined: true,
                          onTap: () => _confirmStatusChange(
                              context, ref, 'active'),
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    _actionButton(
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      color: Colors.red,
                      outlined: true,
                      onTap: () => _confirmDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 160,
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.home_rounded,
              color: AppColors.primary, size: 40),
        ),
      );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(roomRepositoryProvider).deleteRoom(room.id);
        onDeleted();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    WidgetRef ref,
    String newStatus,
  ) async {
    final isRelist = newStatus == 'active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isRelist ? 'Re-list Room' : 'Mark as Rented',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isRelist
              ? 'This will make your listing active again.'
              : 'This will mark your room as rented and hide it from search.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isRelist ? 'Re-list' : 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(roomRepositoryProvider)
            .updateRoomStatus(room.id, newStatus);
        onStatusChanged();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRelist
                    ? 'Room is now active again!'
                    : 'Room marked as rented',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyPostsState extends StatelessWidget {
  final String status;
  final VoidCallback onAddPost;

  const _EmptyPostsState({required this.status, required this.onAddPost});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive
                    ? Icons.post_add_rounded
                    : Icons.check_circle_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isActive ? 'No active listings' : 'No rented listings',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Post your first room to get started!'
                  : 'Rooms you mark as rented will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textGrey, fontSize: 13, height: 1.5),
            ),
            if (isActive) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddPost,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Post a Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
