import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';

import 'package:smilestreatsapp/core/common/widgets/app_cached_image.dart';
import 'package:smilestreatsapp/feature/home/presentation/providers/categories_provider.dart';
import 'package:smilestreatsapp/core/routes/route_endpoint.dart';

class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoryShowsState();
}

class _CategoryShowsState extends ConsumerState<CategoriesView> {
  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Category Shows')),
      body: _buildCategorySection(ref, categoryState),
    );
  }

  Widget _buildCategorySection(WidgetRef ref, CategoriesState categoriesState) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (categoriesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoriesState.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          'Failed to load categories',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 600 ? 4 : 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: categoriesState.categories.length,
        itemBuilder: (context, index) {
          final category = categoriesState.categories[index];
          return GestureDetector(
            onTap: () => context.go(
              '${RoutePaths.search}?category=${Uri.encodeComponent(category.name)}&categoryId=${category.id}',
            ),
            child: Container(
              margin: EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 108.0,
                    height: 108.0,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: AppCachedImage(
                      imageUrl: category.imageUrl ?? "",
                      width: 108.0,
                      height: 108.0,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    category.name.capitalizeFirstOfEach,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
      ),
    );
  }
}
