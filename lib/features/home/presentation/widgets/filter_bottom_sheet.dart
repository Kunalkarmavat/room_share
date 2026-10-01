import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/shared/theme.dart';
import '../providers/home_providers.dart';

// ════════════════════════════════════════════════════════════════
// WHAT: FilterBottomSheet is a modal panel that slides up from
//       the bottom. It lets users filter rooms by:
//         - Area (text field)
//         - Rent range (RangeSlider)
//         - Room type (chip multi-select)
//         - Amenities (chip multi-select)
//
// WHY:  Filters live in a bottom sheet (not a new screen) because:
//       1. User stays in context — they can see results behind it
//       2. Quick to open/close vs full navigation
//       3. Standard mobile UX pattern for filtering
//
// HOW:  This is a ConsumerStatefulWidget because:
//       - LOCAL state: holds the user's IN-PROGRESS filter choices
//         (before they tap "Apply Filters")
//       - RIVERPOD state: on Apply, pushes to roomFilterProvider
//         which triggers roomsProvider to re-fetch
// ════════════════════════════════════════════════════════════════

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // ── Local draft state — only committed on "Apply" ──────────────────────
  final _areaController = TextEditingController();

  // WHAT: RangeValues holds min + max as a pair.
  // WHY:  Flutter's RangeSlider widget requires a RangeValues object.
  // HOW:  RangeValues(5000, 15000) means min=5000, max=15000.
  RangeValues _rentRange = const RangeValues(5000, 15000);

  // WHAT: Nullable String — null means "no room type selected yet."
  // WHY:  We can't use an empty string because .eq('room_type', '')
  //       would query for rooms with empty type — wrong behavior.
  String? _selectedRoomType;

  // WHAT: Set of selected amenities. Set prevents duplicates.
  // WHY:  User can select MULTIPLE amenities (WiFi AND AC etc.)
  // HOW:  toggle() adds if absent, removes if present — perfect for chips.
  final Set<String> _selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    // WHAT: Pre-fill the sheet with the CURRENT active filter.
    // WHY:  If user already filtered by area='Delhi', opening the
    //       sheet should SHOW that — not reset to blank.
    // HOW:  Read current filter from Riverpod on widget init.
    final currentFilter = ref.read(roomFilterProvider);
    _areaController.text = currentFilter.area ?? '';
    _rentRange = RangeValues(
      currentFilter.minRent ?? 5000,
      currentFilter.maxRent ?? 15000,
    );
    _selectedRoomType = currentFilter.roomType;
    if (currentFilter.hasWifi == true) _selectedAmenities.add('WiFi');
    if (currentFilter.hasAc == true) _selectedAmenities.add('AC');
    if (currentFilter.hasFood == true) _selectedAmenities.add('Food Included');
    if (currentFilter.hasLaundry == true) _selectedAmenities.add('Laundry');
  }

  @override
  void dispose() {
    // WHAT: Always dispose controllers to prevent memory leaks.
    // WHY:  TextEditingController holds a reference to the widget tree.
    //       Not disposing = memory leak that grows over time.
    _areaController.dispose();
    super.dispose();
  }

  // ── Apply filters → push to Riverpod → close sheet ──────────────────────
  void _applyFilters() {
    // WHAT: Build a new RoomFilter from local draft state.
    // WHY:  We only commit to global state when user taps Apply.
    //       This way, browsing chips doesn't re-fetch instantly.
    final currentFilter = ref.read(roomFilterProvider);

    ref.read(roomFilterProvider.notifier).state = currentFilter.copyWith(
      area: _areaController.text.trim().isEmpty
          ? null   // null = "don't filter by area"
          : _areaController.text.trim(),
      minRent: _rentRange.start,
      maxRent: _rentRange.end,
      roomType: _selectedRoomType,
      hasWifi: _selectedAmenities.contains('WiFi') ? true : null,
      hasAc: _selectedAmenities.contains('AC') ? true : null,
      hasFood: _selectedAmenities.contains('Food Included') ? true : null,
      hasLaundry: _selectedAmenities.contains('Laundry') ? true : null,
    );

    // WHAT: Pop closes the bottom sheet and returns to the home screen.
    // WHY:  After applying, user wants to see results — not stay in filter.
    Navigator.pop(context);
  }

  // ── Clear all filters → reset to defaults ──────────────────────────────
  void _clearFilters() {
    setState(() {
      _areaController.clear();
      _rentRange = const RangeValues(5000, 15000);
      _selectedRoomType = null;
      _selectedAmenities.clear();
    });

    // WHAT: Also reset the global filter to empty state.
    // HOW:  copyWith with all nulls = no active filters.
    final currentFilter = ref.read(roomFilterProvider);
    ref.read(roomFilterProvider.notifier).state = currentFilter.copyWith(
      area: null,
      minRent: null,
      maxRent: null,
      roomType: null,
      hasWifi: null,
      hasAc: null,
      hasFood: null,
      hasLaundry: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // WHAT: DraggableScrollableSheet lets user drag the bottom sheet
      //       to expand/collapse it with their finger.
      // WHY:  Better UX than a fixed-height sheet. User can see more
      //       of the content behind if they want.
      // HOW:  initialChildSize = starting height as fraction of screen.
      //       minChildSize = minimum before it snaps closed.
      //       maxChildSize = maximum it can expand to.
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false, // WHAT: false = sheet only takes needed space initially
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle indicator ─────────────────────────────────
              _buildDragHandle(),

              // ── Scrollable content ────────────────────────────────────
              Expanded(
                child: ListView(
                  // WHAT: Pass scrollController from DraggableScrollableSheet.
                  // WHY:  This links the ListView scroll to the sheet drag.
                  //       Without this, sheet won't expand when you scroll up.
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildAreaField(),
                    const SizedBox(height: 24),
                    _buildRentRangeSlider(),
                    const SizedBox(height: 24),
                    _buildRoomTypeSection(),
                    const SizedBox(height: 24),
                    _buildAmenitiesSection(),
                    const SizedBox(height: 30),
                    _buildApplyButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── DRAG HANDLE ────────────────────────────────────────────────────────────
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── HEADER: "Filters" + "Clear All" ───────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        GestureDetector(
          onTap: _clearFilters,
          child: const Text(
            'Clear All',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ── AREA FIELD ─────────────────────────────────────────────────────────────
  Widget _buildAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Area'),
        const SizedBox(height: 10),
        TextField(
          controller: _areaController,
          decoration: InputDecoration(
            hintText: 'North Campus, Delhi',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            // WHAT: Suffix icon with location pin — matches design.
            suffixIcon: const Icon(Icons.location_on_outlined,
                color: AppColors.primary, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F5F2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── RENT RANGE SLIDER ──────────────────────────────────────────────────────
  Widget _buildRentRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Rent Range (Monthly)'),
        const SizedBox(height: 12),

        // WHAT: SliderTheme customizes the RangeSlider appearance.
        // WHY:  Default Flutter slider is blue — we need our primary color.
        // HOW:  Wraps the slider and applies theme overrides.
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            // WHAT: trackHeight makes the track line thicker.
            trackHeight: 4,
            // WHAT: RangeThumbShape controls the thumb circle size.
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _rentRange,
            min: 1000,
            max: 50000,
            // WHAT: divisions creates discrete steps.
            // WHY:  Slider jumps in ₹1000 increments — feels intentional.
            // HOW:  divisions = (max - min) / step = 49000/1000 = 49
            divisions: 49,
            onChanged: (RangeValues values) {
              // WHAT: setState triggers local rebuild only.
              // WHY:  We don't apply to global filter yet — only on Apply tap.
              //       This keeps the slider responsive without re-fetching.
              setState(() => _rentRange = values);
            },
          ),
        ),

        // ── Min/Max labels below slider ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _rentLabel('₹${_rentRange.start.toInt()}'),
            _rentLabel('₹${_rentRange.end.toInt()}'),
          ],
        ),
      ],
    );
  }

  // ── ROOM TYPE CHIPS ────────────────────────────────────────────────────────
  Widget _buildRoomTypeSection() {
    // WHAT: Map of display label → DB value.
    // WHY:  User sees "Single Room" but DB stores 'single'.
    //       Keeps UI strings separate from data layer strings.
    final roomTypes = {
      'Single Room': 'single',
      'Shared Room': 'shared',
      'PG/Hostel': 'pg_hostel',
      'Flatmate Required': 'flatmate',
      'Entire Apartment': 'entire_apartment',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Room Type'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roomTypes.entries.map((entry) {
            final isSelected = _selectedRoomType == entry.value;
            return _SelectableChip(
              label: entry.key,
              selected: isSelected,
              onTap: () {
                setState(() {
                  // WHAT: Tapping a selected chip deselects it (toggle).
                  // WHY:  User might want to clear their room type filter.
                  _selectedRoomType =
                      isSelected ? null : entry.value;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── AMENITIES CHIPS ────────────────────────────────────────────────────────
  Widget _buildAmenitiesSection() {
    // WHAT: Each amenity has a label + icon for visual clarity.
    // WHY:  Icons make the chips scannable at a glance.
    final amenities = [
      {'label': 'WiFi', 'icon': Icons.wifi_rounded},
      {'label': 'AC', 'icon': Icons.ac_unit_rounded},
      {'label': 'Food Included', 'icon': Icons.restaurant_rounded},
      {'label': 'Laundry', 'icon': Icons.local_laundry_service_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Amenities'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            final label = amenity['label'] as String;
            final icon = amenity['icon'] as IconData;
            final isSelected = _selectedAmenities.contains(label);

            return _SelectableChip(
              label: label,
              icon: icon,
              selected: isSelected,
              onTap: () {
                setState(() {
                  // WHAT: Set.contains + remove/add = perfect toggle.
                  // WHY:  Multiple amenities can be selected simultaneously.
                  if (isSelected) {
                    _selectedAmenities.remove(label);
                  } else {
                    _selectedAmenities.add(label);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── APPLY BUTTON ───────────────────────────────────────────────────────────
  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Apply Filters'),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _rentLabel(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WHAT: Reusable selectable chip used for Room Type + Amenities.
// WHY:  Both sections need the same visual behavior (select/deselect)
//       so we extract it to avoid duplicating styling code.
// HOW:  Parent manages selected state and passes it as a prop.
//       Chip fires onTap and parent's setState handles the update.
// ════════════════════════════════════════════════════════════════
class _SelectableChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // WHAT: Selected = filled primary bg. Unselected = white with border.
          // WHY:  Clear visual feedback on what's active.
          // HOW:  AnimatedContainer smoothly transitions between the two states.
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
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}