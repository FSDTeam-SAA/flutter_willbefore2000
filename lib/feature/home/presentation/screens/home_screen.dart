import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../product/presentation/providers/products_providers.dart';
import '../../../product/presentation/widgets/product_selection.dart';
import '../providers/categories_provider.dart';
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

    return RefreshIndicator.adaptive(
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
            SizedBox(height: isTablet ? 24 : 20),
            // Header Section
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(h: 20),
                  _buildHeader(isTablet),
                  // SizedBox(height: isTablet ? 24 : 20),
                  // const HomeBanner(),
                  SizedBox(height: isTablet ? 24 : 20),
                  Hero(
                    tag: 'search-bar',
                    createRectTween: (begin, end) {
                      return MaterialRectCenterArcTween(begin: begin, end: end);
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
              onSeeAll: () => context.go(RoutePaths.search),
              isHorizontal: false,
            ),

            // New Arrivals Section
            ProductSection(
              title: 'New Arrivals',
              products: productsState.products.take(4).toList(),
              isLoading: productsState.isLoading,
              onSeeAll: () => context.go(RoutePaths.search),
              isHorizontal: false,
            ),

            // For You Section
            ProductSection(
              title: 'For You',
              products: productsState.products,
              isLoading: productsState.isLoading,
              onSeeAll: () => context.go(RoutePaths.search),
              isHorizontal: true,
            ),

            // Bottom padding
            SizedBox(height: isTablet ? 120 : 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    final user = ref.watch(authProvider.select((state) => state.user));
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final firstName = user?.displayName?.split(' ').first ?? 'User';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome ${user != null ? (firstName.isNotEmpty ? firstName : 'User') : 'Guest'}',
                style: TextStyle(
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
            // Orders Icon
            IconButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                if (!authState.isAuthenticated) {
                  LoginRequiredDialog.show(context);
                } else {
                  context.pushNamed(RoutePaths.orders);
                }
              },
              icon: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textAppBlack,
                size: isTablet ? 26 : 24,
              ),
            ),

            // Notifications Bell with Badge
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    final authState = ref.read(authProvider);
                    if (!authState.isAuthenticated) {
                      LoginRequiredDialog.show(context);
                    } else {
                      context.push(RoutePaths.notification);
                    }
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textAppBlack,
                    size: isTablet ? 26 : 24,
                  ),
                ),
                // Unread Badge
                unreadCount.when(
                  data: (count) {
                    if (count == 0) return const SizedBox();
                    return Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
