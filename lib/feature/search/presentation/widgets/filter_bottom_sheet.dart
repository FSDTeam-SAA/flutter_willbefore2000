import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String sortBy;
  final double minPrice;
  final double maxPrice;
  final Function(String, String, double, double) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.sortBy,
    required this.minPrice,
    required this.maxPrice,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _sortBy;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textAppBlack,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _sortBy = 'Popular';
                      _priceRange = const RangeValues(0, 1000);
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryLaurel,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'All',
                      'Electronics',
                      'Clothing',
                      'Books',
                      'Home',
                      'Sports',
                    ].map((category) {
                      return _buildCategoryChip(category);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Sort By
                  _buildSectionTitle('Sort By'),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      'Popular',
                      'Price: Low to High',
                      'Price: High to Low',
                      'Newest',
                      'Rating',
                    ].map((sort) {
                      return _buildSortOption(sort);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: AppColors.primaryLaurel,
                    inactiveColor: AppColors.primaryLaurel.withOpacity(0.3),
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.round()}',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '\$${_priceRange.end.round()}',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    _selectedCategory,
                    _sortBy,
                    _priceRange.start,
                    _priceRange.end,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLaurel,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textAppBlack,
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLaurel : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLaurel : AppColors.borderColor,
          ),
        ),
        child: Text(
          category,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textAppBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String sort) {
    // final isSelected = _sortBy == sort;
    return RadioListTile<String>(
      title: Text(
        sort,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textAppBlack,
        ),
      ),
      value: sort,
      groupValue: _sortBy,
      activeColor: AppColors.primaryLaurel,
      onChanged: (value) {
        setState(() {
          _sortBy = value!;
        });
      },
    );
  }
}
