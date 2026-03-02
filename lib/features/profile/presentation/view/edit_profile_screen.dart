// lib/features/profile/presentation/screens/edit_profile_screen.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/profile/presentation/state/profile_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/entities/profile_entity.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileEntity profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  File? _newAvatarFile;    // local file picked from device
  bool _isSaving = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with existing profile data
    _nameController =
        TextEditingController(text: widget.profile.fullName ?? '');
    _phoneController =
        TextEditingController(text: widget.profile.phone ?? '');
    _cityController =
        TextEditingController(text: widget.profile.city ?? '');
    _bioController =
        TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ── Pick avatar from camera or gallery ─────────────────────────────────────
  Future<void> _pickAvatar() async {
    // Show bottom sheet to let user choose source
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change Photo',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.gallery);
              },
            ),
            if (widget.profile.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _newAvatarFile = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,   // resize to save storage space
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _newAvatarFile = File(picked.path));
    }
  }

  // ── Save profile ───────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userId = ref.read(supabaseProvider).auth.currentUser!.id;
      String? newAvatarUrl = widget.profile.avatarUrl;

      // Step 1: Upload new avatar if user picked one
      if (_newAvatarFile != null) {
        newAvatarUrl = await ref
            .read(uploadAvatarUsecaseProvider)
            .call(userId, _newAvatarFile!.path);
      }

      // Step 2: Build updated profile entity
      final updatedProfile = widget.profile.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      // Step 3: Save to Supabase via usecase
      await ref
          .read(updateProfileUsecaseProvider)
          .call(updatedProfile);

      // Step 4: Refresh profile provider so ProfileScreen shows new data
      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          // Save button in app bar for quick access
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? AppColors.textGrey : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // ── Avatar section ─────────────────────────────────────────
            _buildAvatarSection(),

            const SizedBox(height: 16),

            // ── Form fields ────────────────────────────────────────────
            _buildFormSection(),

            const SizedBox(height: 24),

            // ── Save button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSaveButton(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Avatar Section ─────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Show new local file OR existing URL OR initials
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.primaryLight, width: 3),
              ),
              child: ClipOval(
                child: _newAvatarFile != null
                    ? Image.file(
                        _newAvatarFile!,
                        fit: BoxFit.cover,
                      )
                    : widget.profile.avatarUrl != null &&
                            widget.profile.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.profile.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                _avatarFallback(),
                            errorWidget: (_, __, ___) =>
                                _avatarFallback(),
                          )
                        : _avatarFallback(),
              ),
            ),

            // Camera button
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    final name = _nameController.text.trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ── Form Fields ────────────────────────────────────────────────────────────
  Widget _buildFormSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          _labeledField(
            label: 'Full Name',
            child: TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Your full name'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ),
          ),

          const SizedBox(height: 14),

          _labeledField(
            label: 'Phone Number',
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('9876543210').copyWith(
                prefixText: '+91  ',
                prefixStyle: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (v.trim().length < 10) return 'Enter valid number';
                return null;
              },
            ),
          ),

          const SizedBox(height: 14),

          _labeledField(
            label: 'City',
            child: TextFormField(
              controller: _cityController,
              decoration: _inputDecoration('e.g. Delhi, Mumbai'),
            ),
          ),

          const SizedBox(height: 14),

          _labeledField(
            label: 'Bio',
            child: TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
              decoration:
                  _inputDecoration('A short description about yourself'),
            ),
          ),

          // Email is read-only — comes from Google Auth
          const SizedBox(height: 14),
          _labeledField(
            label: 'Email',
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.profile.email ?? 'No email',
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
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

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      );

  // ── Save Button ────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text('Save Changes'),
      ),
    );
  }
}
