import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/feature/home/presentation/providers/categories_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/advance_search_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(advancedSearchProvider);
    final categoriesState = ref.watch(categoriesProvider);

    if (categoriesState.isLoading) {
      return SizedBox(
        height: 50,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // FIXED: Check if errorMessage is NOT empty (meaning there's an error)
    if (categoriesState.errorMessage.isNotEmpty) {
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Error loading categories',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Create a list with "All" as first item and real categories
    final allCategories = [
      _CategoryItem(name: 'All', id: null), // null ID for "All"
      ...categoriesState.categories.map(
        (cat) => _CategoryItem(name: cat.name, id: cat.id),
      ),
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final category = allCategories[index];
        final isSelected = searchState.selectedCategory == category.name;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(
              category.name,
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
                  .updateFilters(category: selected ? category.name : 'All');
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

// Helper class to handle both "All" and real categories
class _CategoryItem {
  final String name;
  final String? id;

  _CategoryItem({required this.name, this.id});
}
