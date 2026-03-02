import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/features/home/domain/entities/room_entity.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/providers/home_providers.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PHASE B — Room Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class RoomDetailScreen extends ConsumerStatefulWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomDetailProvider(widget.roomId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: roomAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (room) => _buildContent(room),
      ),
    );
  }

  Widget _buildContent(RoomEntity room) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildImageGallery(room),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndTitle(room),
                  _buildBadges(room),
                  _buildDivider(),
                  _buildDescription(room),
                  _buildDivider(),
                  _buildAmenitiesGrid(room),
                  _buildDivider(),
                  _buildLocationSection(room),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        _buildTopBar(),
        _buildBottomButtons(room),
      ],
    );
  }

  // ── Image Gallery (SliverAppBar with PageView) ────────────────────────────
  Widget _buildImageGallery(RoomEntity room) {
    final images = room.imageUrls.isNotEmpty
        ? room.imageUrls
        : [''];

    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) {
                return images[i].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: AppColors.primaryLight,
                        ),
                        errorWidget: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback();
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImageIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.home_rounded, size: 64, color: AppColors.primary),
        ),
      );

  // ── Top bar (back + share) ────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleIconBtn(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
              ),
              _circleIconBtn(Icons.share_rounded, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }

  // ── Price + Title ─────────────────────────────────────────────────────────
  Widget _buildPriceAndTitle(RoomEntity room) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${room.pricePerMonth.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]},',
                    )}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                ' / month',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            room.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                room.area != null
                    ? '${room.area}, ${room.city}'
                    : room.city,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (room.areaSqft != null) ...[
            const SizedBox(height: 4),
            Text(
              '${room.areaSqft!.toInt()} sq ft',
              style: const TextStyle(
                  color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // ── Badges ────────────────────────────────────────────────────────────────
  Widget _buildBadges(RoomEntity room) {
    final badges = <String>[];
    if (room.isAvailableNow) badges.add('AVAILABLE NOW');
    if (room.studentsOnly) badges.add('STUDENTS ONLY');
    if (room.noBrokerage) badges.add('NO BROKERAGE');
    if (room.genderPreference == 'boys_only') badges.add('BOYS ONLY');
    if (room.genderPreference == 'girls_only') badges.add('GIRLS ONLY');

    if (badges.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: badges
            .map(
              (b) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  b,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Description ───────────────────────────────────────────────────────────
  Widget _buildDescription(RoomEntity room) {
    if (room.description == null || room.description!.isEmpty) {
      return const SizedBox();
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            room.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Amenities Grid ────────────────────────────────────────────────────────
  Widget _buildAmenitiesGrid(RoomEntity room) {
    final amenities = <Map<String, dynamic>>[];
    if (room.hasWifi)
      amenities.add({'icon': Icons.wifi_rounded, 'label': 'WiFi'});
    if (room.hasAc)
      amenities.add({'icon': Icons.ac_unit_rounded, 'label': 'AC'});
    if (room.hasFood)
      amenities.add(
          {'icon': Icons.restaurant_rounded, 'label': 'Food Included'});
    if (room.hasLaundry)
      amenities.add(
          {'icon': Icons.local_laundry_service_rounded, 'label': 'Laundry'});
    if (room.hasSecurity)
      amenities
          .add({'icon': Icons.security_rounded, 'label': 'Security'});

    if (amenities.isEmpty) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: amenities
                .map(
                  (a) => Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          a['icon'] as IconData,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a['label'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Location / Map placeholder ────────────────────────────────────────────
  Widget _buildLocationSection(RoomEntity room) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: room.latitude != null && room.longitude != null
                ? _StaticMapWidget(
                    lat: room.latitude!,
                    lng: room.longitude!,
                  )
                : Container(
                    height: 180,
                    color: AppColors.primaryLight,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 36),
                          SizedBox(height: 6),
                          Text(
                            'Location not provided',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (room.area != null) ...[
            const SizedBox(height: 10),
            Text(
              '${room.area}, ${room.city}',
              style: const TextStyle(
                  color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
        height: 8,
        color: AppColors.background,
      );

  // ── Bottom CTA Buttons ────────────────────────────────────────────────────
  Widget _buildBottomButtons(RoomEntity room) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchPhone(room.phone),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('Call Owner'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(room.phone),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String? phone) async {
  if (phone == null || phone.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No phone number available')),
    );
    return;
  }

  // Strip + and all non-digits → +919156856387 becomes 919156856387
  final clean = phone.trim().replaceAll(RegExp(r'[^\d]'), '');
  final uri = Uri.parse('https://wa.me/$clean');

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Is it installed?'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

Future<void> _launchPhone(String? phone) async {
  if (phone == null || phone.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No phone number available')),
    );
    return;
  }

  final clean = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri(scheme: 'tel', path: clean);

  try {
    await launchUrl(uri);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make call: $e')),
      );
    }
  }
}


}

// ── Static Map Widget (uses OpenStreetMap tile) ───────────────────────────────
class _StaticMapWidget extends StatelessWidget {
  final double lat;
  final double lng;
  const _StaticMapWidget({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    // Uses openstreetmap static tiles — no API key required
    final url =
        'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=15&size=600x200&markers=$lat,$lng,red-pushpin';
    return CachedNetworkImage(
      imageUrl: url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 180,
        color: AppColors.primaryLight,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 180,
        color: AppColors.primaryLight,
        child: const Center(
          child: Icon(Icons.map_outlined,
              color: AppColors.primary, size: 48),
        ),
      ),
    );
  }
}
