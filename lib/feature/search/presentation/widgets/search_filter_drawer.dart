import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/advance_search_provider.dart';

class SearchFilterDrawer extends ConsumerStatefulWidget {
  const SearchFilterDrawer({super.key});

  @override
  ConsumerState<SearchFilterDrawer> createState() => _SearchFilterDrawerState();
}

class _SearchFilterDrawerState extends ConsumerState<SearchFilterDrawer> {
  late String _selectedCategory;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    final searchState = ref.read(advancedSearchProvider);
    _selectedCategory = searchState.selectedCategory;
    _priceRange = RangeValues(searchState.minPrice, searchState.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLaurel,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(),
                    const SizedBox(height: 24),
                    _buildPriceSection(),
                    const SizedBox(height: 24),
                    _buildRatingSection(),
                    const SizedBox(height: 24),
                    _buildBrandSection(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryLaurel),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.primaryLaurel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLaurel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.notoSansKr(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            'Beauty',
            'Automotive',
          ].map((category) => _buildCategoryChip(category)).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            setState(() => _priceRange = values);
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
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rating'),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            title: Text(
              '$rating & up',
              style: GoogleFonts.notoSansKr(fontSize: 14),
            ),
            trailing: Checkbox(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primaryLaurel,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Brand'),
        const SizedBox(height: 8),
        ...['Apple', 'Samsung', 'Nike', 'Adidas', 'Sony'].map((brand) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              brand,
              style: GoogleFonts.notoSansKr(fontSize: 14),
            ),
            value: false,
            onChanged: (value) {},
            activeColor: AppColors.primaryLaurel,
          );
        }),
      ],
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
        setState(() => _selectedCategory = category);
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

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _priceRange = const RangeValues(0, 1000);
    });
  }

  void _applyFilters() {
    ref.read(advancedSearchProvider.notifier).updateFilters(
      category: _selectedCategory,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
    );
    Navigator.pop(context);
  }
}
