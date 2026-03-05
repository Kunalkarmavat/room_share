import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/routes/app_transitions.dart';
import 'package:room_share/features/home/presentation/screens/room_detail_screen.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/room_entity.dart';
import '../providers/home_providers.dart';


class RoomCard extends ConsumerStatefulWidget {
  final RoomEntity room;
  const RoomCard({super.key, required this.room});

  @override
  ConsumerState<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends ConsumerState<RoomCard> {
  late bool _isFavorited;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.room.isFavorited;
  }

  Future<void> _handleFavoriteToggle() async {
    if (_isTogglingFavorite) return;
    setState(() {
      _isFavorited = !_isFavorited;
      _isTogglingFavorite = true;
    });
    try {
      await ref.read(roomRepositoryProvider).toggleFavorite(widget.room.id);
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _isFavorited = !_isFavorited);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return GestureDetector(
      // Tapping anywhere on the card also opens detail
      onTap: () => _openDetail(context, room.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(room),
            _buildTitleRow(room),
            _buildLocation(room),
            _buildBottomRow(context, room),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String roomId) {

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => RoomDetailScreen(roomId: roomId),
    //   ),
    // );

    Navigator.push(
      context,
      AppTransitions.fadeThrough(
        page: RoomDetailScreen(roomId: roomId),
      ),
     
    );

    
    

    
  }

  // ── Image section ─────────────────────────────────────────────────────────
  Widget _buildImageSection(RoomEntity room) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
          child: room.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: room.imageUrls.first,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildImageShimmer(),
                  errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        ),

     

        // Favorite button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _handleFavoriteToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: RoomShareColors.onPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    
                    _isFavorited
                        ? Icons.favorite
                        : Icons.favorite_border,
                    key: ValueKey(_isFavorited),
                    color:
                        _isFavorited ? AppColors.primary :  AppColors.textDark.withOpacity(0.7) ,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Multiple images indicator
        if (room.imageUrls.length > 1)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      color: Colors.white, size: 11),
                  const SizedBox(width: 3),
                  Text(
                    '1/${room.imageUrls.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Title + Rating ────────────────────────────────────────────────────────
  Widget _buildTitleRow(RoomEntity room) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              room.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
         Text(
           '₹ ${room.pricePerMonth.toInt()}/mo',
         style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
         ),
        ],
      ),
    );
  }

  // ── Location ──────────────────────────────────────────────────────────────
  Widget _buildLocation(RoomEntity room) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: RoomShareColors.primary, size: 14),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              room.area != null
                  ? '${room.area}, ${room.city}'
                  : room.city,
              style: const TextStyle(
                color: RoomShareColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom row: badges + View Details ────────────────────────────────────
  Widget _buildBottomRow(BuildContext context, RoomEntity room) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (room.isAvailableNow) _badge('AVAILABLE NOW'),
                if (room.studentsOnly) _badge('STUDENTS ONLY'),
                if (room.noBrokerage) _badge('NO BROKERAGE'),
                if (room.genderPreference == 'boys_only')
                  _badge('BOYS ONLY'),
                if (room.genderPreference == 'girls_only')
                  _badge('GIRLS ONLY'),
              ],
            ),


            
          ),

   // ── NEW: Verified Owner badge ──────────────────────────
              if (room.isOwnerVerified) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Verified Owner',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
          height: 190,
          width: double.infinity,
          color: Colors.grey.shade200),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Icon(Icons.home_rounded,
            size: 48, color: RoomShareColors.primary),
      ),
    );
  }
}