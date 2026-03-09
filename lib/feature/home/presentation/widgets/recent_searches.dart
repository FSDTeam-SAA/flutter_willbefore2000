import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/search_provider.dart';

class HomeRecentSearches extends ConsumerWidget {
  final Function(String) onSearchTap;

  const HomeRecentSearches({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (searchState.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textAppBlack,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearRecentSearches();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 16 : 12),

        ...searchState.recentSearches
            .map(
              (search) => Container(
                margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  child: InkWell(
                    onTap: () => onSearchTap(search),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 14 : 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: isTablet ? 20 : 18,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: isTablet ? 12 : 10),
                          Expanded(
                            child: Text(
                              search,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: AppColors.textAppBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.north_west,
                            size: isTablet ? 16 : 14,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
