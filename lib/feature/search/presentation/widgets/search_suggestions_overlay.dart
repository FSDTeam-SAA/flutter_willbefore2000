import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/advance_search_provider.dart';

class SearchSuggestionsOverlay extends ConsumerWidget {
  final Function(String) onSuggestionTap;
  final VoidCallback onDismiss;

  const SearchSuggestionsOverlay({
    super.key,
    required this.onSuggestionTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(advancedSearchProvider);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80), // Space for search header
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchState.searchHistory.isNotEmpty) ...[
                      _buildSectionHeader('Recent Searches'),
                      ...searchState.searchHistory.take(5).map((search) {
                        return _buildSuggestionItem(
                          search,
                          Icons.history,
                          onSuggestionTap,
                        );
                      }),
                    ],
                    // if (searchState.popularSearches.isNotEmpty) ...[
                    //   _buildSectionHeader('Popular Searches'),
                    //   ...searchState.popularSearches.take(6).map((search) {
                    //     return _buildSuggestionItem(
                    //       search,
                    //       Icons.trending_up,
                    //       onSuggestionTap,
                    //     );
                    //   }),
                    // ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    String suggestion,
    IconData icon,
    Function(String) onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryHintColor, size: 20),
      title: Text(
        suggestion,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: AppColors.textAppBlack,
        ),
      ),
      onTap: () => onTap(suggestion),
      dense: true,
    );
  }
}
