import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../product/presentation/providers/products_providers.dart';
import '../../../product/presentation/widgets/product_selection.dart';
import '../providers/categories_provider.dart';
import '../widgets/home_banner.dart';
import '../widgets/category_section.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).fetchProducts();
      ref.read(categoriesProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            await ref.read(productsProvider.notifier).fetchProducts();
            await ref.read(categoriesProvider.notifier).fetchCategories();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isTablet),
                      SizedBox(height: isTablet ? 24 : 20),
                      const HomeBanner(),
                      SizedBox(height: isTablet ? 24 : 20),
                      Hero(
                        tag: 'search-bar',
                        createRectTween: (begin, end) {
                          return MaterialRectCenterArcTween(
                            begin: begin,
                            end: end,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: HomeSearchBarWidget(
                            onTap: () => context.push(RoutePaths.homeSearch),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories Section
                CategorySection(
                  categories: categoriesState.categories,
                  isLoading: categoriesState.isLoading,
                ),

                // Most Popular Section
                ProductSection(
                  title: 'Most Popular',
                  products: productsState.products.take(4).toList(),
                  isLoading: productsState.isLoading,
                  onSeeAll: () => context.go(
                    '${RoutePaths.productList}/popular?title=Most Popular',
                  ),
                  isHorizontal: false,
                ),

                // New Arrivals Section
                ProductSection(
                  title: 'New Arrivals',
                  products: productsState.products.take(4).toList(),
                  isLoading: productsState.isLoading,
                  onSeeAll: () => context.go(
                    '${RoutePaths.productList}/new-arrivals?title=New Arrivals',
                  ),
                  isHorizontal: false,
                ),

                // For You Section
                ProductSection(
                  title: 'For You',
                  products: productsState.products,
                  isLoading: productsState.isLoading,
                  onSeeAll: () => context.go(
                    '${RoutePaths.productList}/for-you?title=For You',
                  ),
                  isHorizontal: true,
                ),

                // Bottom padding
                SizedBox(height: isTablet ? 120 : 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Alex 👋',
                style: GoogleFonts.notoSansKr(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textAppBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                context.pushNamed(RoutePaths.orders);
              },
              icon: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textAppBlack,
                size: isTablet ? 26 : 24,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.textAppBlack,
                size: isTablet ? 26 : 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
