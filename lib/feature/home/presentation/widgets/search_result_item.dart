import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/search_provider.dart';

class HomeSearchResultItem extends StatelessWidget {
  final HomeSearchResult result;
  final String query;
  final VoidCallback onTap;

  const HomeSearchResultItem({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Row(
              children: [
                // Image or Icon
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    color: Colors.grey[100],
                  ),
                  child: result.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 12 : 8,
                          ),
                          child: Image.network(
                            result.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultIcon(isTablet);
                            },
                          ),
                        )
                      : _buildDefaultIcon(isTablet),
                ),

                SizedBox(width: isTablet ? 16 : 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with highlighted search term
                      RichText(
                        text: _buildHighlightedText(
                          result.title,
                          query,
                          GoogleFonts.notoSansKr(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textAppBlack,
                          ),
                          GoogleFonts.notoSansKr(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLaurel,
                            backgroundColor: AppColors.primaryLaurel
                                .withOpacity(0.1),
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (result.subtitle != null) ...[
                        SizedBox(height: isTablet ? 6 : 4),
                        Text(
                          result.subtitle!,
                          style: GoogleFonts.notoSansKr(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      SizedBox(height: isTablet ? 6 : 4),

                      // Type indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: result.type == HomeSearchResultType.product
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                        ),
                        child: Text(
                          result.type == HomeSearchResultType.product
                              ? 'Product'
                              : 'Category',
                          style: GoogleFonts.notoSansKr(
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.w500,
                            color: result.type == HomeSearchResultType.product
                                ? Colors.blue[700]
                                : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 18 : 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(bool isTablet) {
    return Icon(
      result.type == HomeSearchResultType.product
          ? Icons.shopping_bag_outlined
          : Icons.category_outlined,
      size: isTablet ? 28 : 24,
      color: Colors.grey[400],
    );
  }

  TextSpan _buildHighlightedText(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: highlightStyle,
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: normalStyle));
    }

    return TextSpan(children: spans);
  }
}
