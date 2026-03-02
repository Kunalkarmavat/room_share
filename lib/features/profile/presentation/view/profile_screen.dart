// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/profile/presentation/state/profile_providers.dart';
import '../../../home/presentation/screens/my_posts_screen.dart';
import '../../../home/presentation/screens/saved_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          profileAsync.whenData(
            (profile) => IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(profile: profile),
                ),
              ).then((_) => ref.invalidate(profileProvider)),
            ),
          ).value ??
              const SizedBox(),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _buildError(context, ref, e.toString()),
        data: (profile) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(profileProvider.future),
          child: ListView(
            children: [
              // ── Avatar + name + email ────────────────────────────────────
              _buildProfileHeader(context, ref, profile),

              const SizedBox(height: 12),

              // ── Info cards (phone, city, bio) ────────────────────────────
              _buildInfoSection(profile),

              const SizedBox(height: 12),

              // ── Quick actions ────────────────────────────────────────────
              _buildActionsSection(context, ref),

              const SizedBox(height: 12),

              // ── Logout ───────────────────────────────────────────────────
              _buildLogoutButton(context, ref),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────
  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, profile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryLight, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile.avatarUrl != null &&
                          profile.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profile.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _avatarPlaceholder(profile),
                          errorWidget: (_, __, ___) =>
                              _avatarPlaceholder(profile),
                        )
                      : _avatarPlaceholder(profile),
                ),
              ),
              // Edit badge on avatar
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfileScreen(profile: profile),
                  ),
                ).then((_) => ref.invalidate(profileProvider)),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            profile.fullName?.isNotEmpty == true
                ? profile.fullName!
                : 'No name set',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          if (profile.email != null)
            Text(
              profile.email!,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),

          const SizedBox(height: 14),

          // Edit Profile button
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(profile: profile),
              ),
            ).then((_) => ref.invalidate(profileProvider)),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(profile) {
    final name = profile.fullName ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ── Info Section ───────────────────────────────────────────────────────────
  Widget _buildInfoSection(profile) {
    final hasAnyInfo = (profile.phone?.isNotEmpty ?? false) ||
        (profile.city?.isNotEmpty ?? false) ||
        (profile.bio?.isNotEmpty ?? false);

    if (!hasAnyInfo) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          if (profile.phone?.isNotEmpty ?? false)
            _infoRow(Icons.phone_outlined, profile.phone!),
          if (profile.city?.isNotEmpty ?? false)
            _infoRow(Icons.location_on_outlined, profile.city!),
          if (profile.bio?.isNotEmpty ?? false)
            _infoRow(Icons.info_outline_rounded, profile.bio!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions Section ────────────────────────────────────────────────────────
  Widget _buildActionsSection(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _actionTile(
            icon: Icons.home_outlined,
            label: 'My Posts',
            subtitle: 'Manage your listings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPostsScreen()),
            ),
          ),
          _divider(),
          _actionTile(
            icon: Icons.favorite_outline_rounded,
            label: 'Saved Rooms',
            subtitle: 'Rooms you have liked',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedScreen()),
            ),
          ),
          _divider(),
          _actionTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            subtitle: 'Manage your alerts',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon!')),
            ),
          ),
          _divider(),
          _actionTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            subtitle: 'FAQs and contact us',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon!')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textGrey),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 72,
        color: AppColors.border,
      );

  // ── Logout Button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: _actionTile(
        icon: Icons.logout_rounded,
        label: 'Log Out',
        subtitle: 'Sign out of your account',
        onTap: () => _confirmLogout(context, ref),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Are you sure you want to log out?'),
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
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(signOutUsecaseProvider).call();
      // Navigate back to login screen — clear entire navigation stack
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // change this to your actual login route
          (route) => false,
        );
      }
    }
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load profile',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(profileProvider),
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
