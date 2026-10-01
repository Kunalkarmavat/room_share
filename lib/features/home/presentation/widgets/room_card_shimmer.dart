import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ════════════════════════════════════════════════════════════════
// WHAT: A skeleton placeholder that mimics the RoomCard layout.
// WHY:  Shows users WHERE content will appear while it loads.
//       Much better UX than a spinner — users can anticipate layout.
// HOW:  Uses Shimmer package to animate the grey blocks.
//       Shown while roomsProvider is in AsyncLoading state.
// ════════════════════════════════════════════════════════════════

class RoomCardShimmer extends StatelessWidget {
  const RoomCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      // WHAT: period controls shimmer speed.
      // WHY:  1.5s feels natural — not too fast (anxious) or too slow.
      period: const Duration(milliseconds: 1500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 190,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 16, width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle placeholder
                  Container(height: 12, width: 160, color: Colors.white),
                  const SizedBox(height: 14),
                  // Badge + button row placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 26, width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 36, width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WHAT: Shows a list of shimmer cards during loading.
// HOW:  Used in HomeScreen loading state.
class RoomListShimmer extends StatelessWidget {
  const RoomListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // WHAT: 4 skeleton cards give impression of a full list.
      // WHY:  Too few (1-2) looks broken. Too many wastes render time.
      itemCount: 4,
      itemBuilder: (_, __) => const RoomCardShimmer(),
    );
  }
}