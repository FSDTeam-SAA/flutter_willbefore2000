import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/advance_search_provider.dart';
import '../providers/search_filter_provider.dart';

class SearchFilterDrawer extends ConsumerWidget {
  const SearchFilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(searchFilterProvider);
    
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
                    _buildCategorySection(ref, filterState),
                    const SizedBox(height: 24),
                    _buildPriceSection(ref, filterState),
                    const SizedBox(height: 24),
                    _buildRatingSection(ref, filterState),
                    const SizedBox(height: 24),
                    _buildBrandSection(ref, filterState),
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
                      onPressed: () => _resetFilters(ref),
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
                      onPressed: () => _applyFilters(context, ref, filterState),
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

  Widget _buildCategorySection(WidgetRef ref, SearchFilterState filterState) {
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
          ].map((category) => _buildCategoryChip(ref, category, filterState.selectedCategory)).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection(WidgetRef ref, SearchFilterState filterState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Price Range'),
        const SizedBox(height: 12),
        RangeSlider(
          values: filterState.priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
          activeColor: AppColors.primaryLaurel,
          inactiveColor: AppColors.primaryLaurel.withOpacity(0.3),
          labels: RangeLabels(
            '\$${filterState.priceRange.start.round()}',
            '\$${filterState.priceRange.end.round()}',
          ),
          onChanged: (values) {
            ref.read(searchFilterProvider.notifier).updatePriceRange(values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${filterState.priceRange.start.round()}',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
            Text(
              '\$${filterState.priceRange.end.round()}',
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

  Widget _buildRatingSection(WidgetRef ref, SearchFilterState filterState) {
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
              value: filterState.selectedRatings.contains(rating),
              onChanged: (value) {
                ref.read(searchFilterProvider.notifier).toggleRating(rating);
              },
              activeColor: AppColors.primaryLaurel,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBrandSection(WidgetRef ref, SearchFilterState filterState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Brand'),
        const SizedBox(height: 8),
        ...['Apple', 'Samsung', 'Nike', 'Adidas', 'Sony'].map((brand) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(brand, style: GoogleFonts.notoSansKr(fontSize: 14)),
            value: filterState.selectedBrands.contains(brand),
            onChanged: (value) {
              ref.read(searchFilterProvider.notifier).toggleBrand(brand);
            },
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

  Widget _buildCategoryChip(WidgetRef ref, String category, String selectedCategory) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        ref.read(searchFilterProvider.notifier).updateCategory(category);
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

  void _resetFilters(WidgetRef ref) {
    ref.read(searchFilterProvider.notifier).resetFilters();
  }

  void _applyFilters(BuildContext context, WidgetRef ref, SearchFilterState filterState) {
    ref
        .read(advancedSearchProvider.notifier)
        .updateFilters(
          category: filterState.selectedCategory,
          minPrice: filterState.priceRange.start,
          maxPrice: filterState.priceRange.end,
        );
    Navigator.pop(context);
  }
}
