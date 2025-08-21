import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/advance_search_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(advancedSearchProvider);

    final categories = [
      'All',
      'Electronics',
      'Clothing',
      'Books',
      'Home',
      'Sports',
      'Beauty',
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = searchState.selectedCategory == category;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(
              category,
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textAppBlack,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              ref
                  .read(advancedSearchProvider.notifier)
                  .updateFilters(category: selected ? category : 'All');
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLaurel,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryLaurel
                  : AppColors.borderColor,
            ),
          ),
        );
      },
    );
  }
}
