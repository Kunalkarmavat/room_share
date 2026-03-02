import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_share/core/services/supabase_provider.dart';
import 'package:room_share/features/home/data/models/room_model.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/home/presentation/providers/home_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PHASE C — Add New Post Screen
// ─────────────────────────────────────────────────────────────────────────────

// Provider for tracking submission state
final _isSubmittingProvider = StateProvider<bool>((_) => false);

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _sqftController = TextEditingController();
  final _phoneController = TextEditingController();

  String _roomType = 'single';
  String _genderPreference = 'any';
  bool _hasWifi = false;
  bool _hasAc = false;
  bool _hasFood = false;
  bool _hasLaundry = false;
  bool _hasSecurity = false;
  bool _isAvailableNow = true;
  bool _studentsOnly = false;
  bool _noBrokerage = false;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _sqftController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final remaining = 5 - _selectedImages.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      final toAdd = picked.take(remaining).map((x) => File(x.path)).toList();
      setState(() => _selectedImages.addAll(toAdd));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 1 photo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser!.id;

      final room = RoomModel(
        id: '',
        ownerId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim().isEmpty
            ? null
            : _areaController.text.trim(),
        pricePerMonth: double.parse(_rentController.text.trim()),
        areaSqft: _sqftController.text.trim().isEmpty
            ? null
            : double.tryParse(_sqftController.text.trim()),
        phone: _phoneController.text.trim(),
        roomType: _roomType,
        genderPreference: _genderPreference,
        status: 'active',
        hasWifi: _hasWifi,
        hasAc: _hasAc,
        hasFood: _hasFood,
        hasLaundry: _hasLaundry,
        hasSecurity: _hasSecurity,
        isAvailableNow: _isAvailableNow,
        studentsOnly: _studentsOnly,
        noBrokerage: _noBrokerage,
        createdAt: DateTime.now(),
      );

      await ref
          .read(roomRepositoryProvider)
          .createRoom(room, _selectedImages.map((f) => f.path).toList());

      ref.invalidate(roomsProvider);
      ref.invalidate(myRoomsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(_isSubmittingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(_isSubmittingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Post',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: isSubmitting ? null : 0,
            backgroundColor: Colors.transparent,
            color: isSubmitting ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPhotoUpload(),
            const SizedBox(height: 20),
            _buildSection('Post Title', _buildTitleField()),
            const SizedBox(height: 16),
            _buildSection('Description', _buildDescriptionField()),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildSection('Rent (₹/month)', _buildRentField())),
              const SizedBox(width: 12),
              Expanded(child: _buildSection('Area (sq ft)', _buildSqftField())),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildSection('City', _buildCityField())),
              const SizedBox(width: 12),
              Expanded(child: _buildSection('Area/Locality', _buildAreaField())),
            ]),
            const SizedBox(height: 16),
            _buildSection('Phone Number', _buildPhoneField()),
            const SizedBox(height: 20),
            _buildRoomTypeSection(),
            const SizedBox(height: 20),
            _buildGenderSection(),
            const SizedBox(height: 20),
            _buildAmenitiesSection(),
            const SizedBox(height: 20),
            _buildTagsSection(),
            const SizedBox(height: 28),
            _buildPublishButton(isSubmitting),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Photo Upload ──────────────────────────────────────────────────────────
  Widget _buildPhotoUpload() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Upload Photos',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add up to 5 clear photos of the room',
                      style:
                          TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length < 5
                    ? _selectedImages.length + 1
                    : _selectedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == _selectedImages.length && _selectedImages.length < 5) {
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImages[i],
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedImages.removeAt(i)),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: Text(_selectedImages.isEmpty
                ? 'Add Images'
                : 'Add More (${_selectedImages.length}/5)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // ── Text fields ───────────────────────────────────────────────────────────
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
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

  Widget _buildTitleField() => TextFormField(
        controller: _titleController,
        decoration:
            _inputDecoration('e.g. Spacious 1BHK near University'),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Title is required' : null,
      );

  Widget _buildDescriptionField() => TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: _inputDecoration(
            'Describe the room, nearby places, house rules...'),
        validator: (v) => v == null || v.trim().length < 20
            ? 'Add at least 20 characters'
            : null,
      );

  Widget _buildRentField() => TextFormField(
        controller: _rentController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration('6000'),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (double.tryParse(v) == null) return 'Invalid';
          return null;
        },
      );

  Widget _buildSqftField() => TextFormField(
        controller: _sqftController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration('500'),
      );

  Widget _buildCityField() => TextFormField(
        controller: _cityController,
        decoration: _inputDecoration('Delhi'),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Required' : null,
      );

  Widget _buildAreaField() => TextFormField(
        controller: _areaController,
        decoration: _inputDecoration('North Campus'),
      );

  Widget _buildPhoneField() => TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration('9876543210').copyWith(
          prefixText: '+91  ',
          prefixStyle: const TextStyle(
              color: AppColors.textDark, fontWeight: FontWeight.w500),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (v.trim().length < 10) return 'Enter valid number';
          return null;
        },
      );

  // ── Room Type ─────────────────────────────────────────────────────────────
  Widget _buildRoomTypeSection() {
    const types = {
      'single': 'Single Room',
      'shared': 'Shared Room',
      'pg_hostel': 'PG/Hostel',
      'flatmate': 'Flatmate Required',
      'entire_apartment': 'Entire Apartment',
    };
    return _buildChipGroupSection(
      'Room Type',
      types.entries.map((e) {
        return _ChipOption(
          label: e.value,
          selected: _roomType == e.key,
          onTap: () => setState(() => _roomType = e.key),
        );
      }).toList(),
    );
  }

  // ── Gender Preference ─────────────────────────────────────────────────────
  Widget _buildGenderSection() {
    const genders = {
      'any': 'Any',
      'boys_only': 'Boys Only',
      'girls_only': 'Girls Only',
    };
    return _buildChipGroupSection(
      'Gender Preference',
      genders.entries.map((e) {
        return _ChipOption(
          label: e.value,
          selected: _genderPreference == e.key,
          onTap: () => setState(() => _genderPreference = e.key),
        );
      }).toList(),
    );
  }

  // ── Amenities ─────────────────────────────────────────────────────────────
  Widget _buildAmenitiesSection() {
    return _buildChipGroupSection(
      'Amenities',
      [
        _ChipOption(
          label: 'WiFi',
          icon: Icons.wifi_rounded,
          selected: _hasWifi,
          onTap: () => setState(() => _hasWifi = !_hasWifi),
        ),
        _ChipOption(
          label: 'AC',
          icon: Icons.ac_unit_rounded,
          selected: _hasAc,
          onTap: () => setState(() => _hasAc = !_hasAc),
        ),
        _ChipOption(
          label: 'Food Included',
          icon: Icons.restaurant_rounded,
          selected: _hasFood,
          onTap: () => setState(() => _hasFood = !_hasFood),
        ),
        _ChipOption(
          label: 'Laundry',
          icon: Icons.local_laundry_service_rounded,
          selected: _hasLaundry,
          onTap: () => setState(() => _hasLaundry = !_hasLaundry),
        ),
        _ChipOption(
          label: 'Security',
          icon: Icons.security_rounded,
          selected: _hasSecurity,
          onTap: () => setState(() => _hasSecurity = !_hasSecurity),
        ),
      ],
    );
  }

  // ── Tags ─────────────────────────────────────────────────────────────────
  Widget _buildTagsSection() {
    return _buildChipGroupSection(
      'Additional Tags',
      [
        _ChipOption(
          label: 'Available Now',
          selected: _isAvailableNow,
          onTap: () => setState(() => _isAvailableNow = !_isAvailableNow),
        ),
        _ChipOption(
          label: 'Students Only',
          selected: _studentsOnly,
          onTap: () => setState(() => _studentsOnly = !_studentsOnly),
        ),
        _ChipOption(
          label: 'No Brokerage',
          selected: _noBrokerage,
          onTap: () => setState(() => _noBrokerage = !_noBrokerage),
        ),
      ],
    );
  }

  Widget _buildChipGroupSection(String label, List<Widget> chips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              )),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  // ── Publish Button ────────────────────────────────────────────────────────
  Widget _buildPublishButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text('Publish Listing'),
      ),
    );
  }
}

// ── Reusable Chip Option ──────────────────────────────────────────────────────
class _ChipOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChipOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textGrey),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
