import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';
import 'package:smilestreats/feature/home/domain/models/category_model.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isLoading;

  const CategorySection({
    super.key,
    required this.categories,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final categoryHeight = isTablet ? 120.0 : 100.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            child: Text(
              'Categories',
              style: GoogleFonts.notoSansKr(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textAppBlack,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          SizedBox(
            height: categoryHeight,
            child: isLoading
                ? _buildLoadingState(isTablet)
                : categories.isEmpty
                ? _buildEmptyState(isTablet)
                : _buildCategoryList(isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    final itemWidth = isTablet ? 100.0 : 80.0;
    final iconSize = isTablet ? 60.0 : 50.0;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: itemWidth,
          margin: EdgeInsets.only(right: isTablet ? 16 : 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Container(
                height: isTablet ? 12 : 10,
                width: iconSize * 0.8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Text(
        'No categories available',
        style: GoogleFonts.notoSansKr(
          fontSize: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool isTablet) {
    final itemWidth = isTablet ? 100.0 : 80.0;
    final iconSize = isTablet ? 60.0 : 50.0;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => context.go(
            '${RoutePaths.productList}/category/${category.id}?title=${category.name}',
          ),
          child: Container(
            width: itemWidth,
            margin: EdgeInsets.only(right: isTablet ? 16 : 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLaurel.withOpacity(0.1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.primaryLaurel.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: AppCachedImage(
                    imageUrl: category.imageUrl ?? "",
                    width: 75,
                    height: 80,
                  ),

                  // Icon(
                  //   _getCategoryIcon(category.name),
                  //   color: AppColors.primaryLaurel,
                  //   size: iconInnerSize,
                  // ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  category.name,
                  style: GoogleFonts.notoSansKr(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textAppBlack,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
