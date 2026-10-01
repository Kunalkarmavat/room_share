import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/features/home/domain/entities/room_entity.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/providers/home_providers.dart';


// ─────────────────────────────────────────────────────────────────────────────
// PHASE E — Saved / Favorites Screen
// ─────────────────────────────────────────────────────────────────────────────

// Provider: fetch only favorited rooms
final savedRoomsProvider = FutureProvider.autoDispose<List<RoomEntity>>((ref) {
  return ref.read(roomRepositoryProvider).getFavorites();
});

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: savedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) => rooms.isEmpty
            ? const _EmptySavedState()
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.refresh(savedRoomsProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (_, i) => _SavedRoomCard(
                    room: rooms[i],
                    onRemoved: () => ref.invalidate(savedRoomsProvider),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Saved Room Card ───────────────────────────────────────────────────────────
class _SavedRoomCard extends ConsumerStatefulWidget {
  final RoomEntity room;
  final VoidCallback onRemoved;

  const _SavedRoomCard({required this.room, required this.onRemoved});

  @override
  ConsumerState<_SavedRoomCard> createState() => _SavedRoomCardState();
}

class _SavedRoomCardState extends ConsumerState<_SavedRoomCard> {
  bool _removing = false;

  Future<void> _removeFromSaved() async {
    setState(() => _removing = true);
    try {
      await ref
          .read(roomRepositoryProvider)
          .toggleFavorite(widget.room.id);
      widget.onRemoved();
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

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
      child: Row(
        children: [
          // ── Thumbnail ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16)),
            child: room.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: room.imageUrls.first,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 110,
                      height: 110,
                      color: AppColors.primaryLight,
                    ),
                    errorWidget: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),
          ),

          // ── Details ────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _removing ? null : _removeFromSaved,
                        child: _removing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary),
                              )
                            : const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.primary, size: 12),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          room.area != null
                              ? '${room.area}, ${room.city}'
                              : room.city,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${room.pricePerMonth.toInt()}/mo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.amber, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            room.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO Phase B: Navigate to detail
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (_) => RoomDetailScreen(roomId: room.id)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
        width: 110,
        height: 110,
        color: AppColors.primaryLight,
        child: const Icon(Icons.home_rounded,
            color: AppColors.primary, size: 36),
      );
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No saved rooms yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the heart icon on any room\nto save it here for later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
