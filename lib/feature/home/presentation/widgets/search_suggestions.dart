import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/providers/categories_provider.dart';

class HomeSearchSuggestions extends ConsumerWidget {
  final Function(String) onSuggestionTap;

  const HomeSearchSuggestions({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final suggestions = [
      'Popular products',
      'New arrivals',
      'Best sellers',
      'On sale',
      ...categoriesState.categories.take(4).map((cat) => cat.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12),

        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: suggestions
              .map(
                (suggestion) => GestureDetector(
                  onTap: () => onSuggestionTap(suggestion),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 10 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppColors.textAppBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
