import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../providers/search_provider.dart';
import '../widgets/search_result_item.dart';
import '../widgets/search_suggestions.dart';
import '../widgets/recent_searches.dart';

class HomeSearchScreen extends ConsumerStatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  ConsumerState<HomeSearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<HomeSearchScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Auto focus and start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchProvider.notifier).search(query);
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).addToRecentSearches(query.trim());
      _focusNode.unfocus();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Clear search when user goes back
          // Use Future.microtask to avoid modifying provider during build
          Future.microtask(() {
            ref.read(searchProvider.notifier).clearSearch();
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Search Header with Hero Animation
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.05),
                //       blurRadius: 10,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () {
                        // Clear search when user explicitly goes back
                        ref.read(searchProvider.notifier).clearSearch();
                        context.pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.textAppBlack,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Hero Search Bar
                    Expanded(
                      child: Hero(
                        tag: 'search-bar',
                        createRectTween: (begin, end) {
                          return MaterialRectCenterArcTween(
                            begin: begin,
                            end: end,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            height: isTablet ? 56 : 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                isTablet ? 28 : 25,
                              ),
                              border: Border.all(
                                color: _focusNode.hasFocus
                                    ? AppColors.primaryLaurel
                                    : Colors.grey[200]!,
                                width: _focusNode.hasFocus ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: isTablet ? 20 : 16),
                                Icon(
                                  Icons.search,
                                  color: _focusNode.hasFocus
                                      ? AppColors.primaryLaurel
                                      : Colors.grey[400],
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 16 : 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _focusNode,
                                    onChanged: _onSearchChanged,
                                    onSubmitted: _onSearchSubmitted,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: isTablet ? 16 : 14,
                                      color: AppColors.textAppBlack,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search products, categories...',
                                      hintStyle: GoogleFonts.notoSansKr(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.grey[500],
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    onPressed: _clearSearch,
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[400],
                                      size: isTablet ? 20 : 18,
                                    ),
                                  ),
                                SizedBox(width: isTablet ? 12 : 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSearchContent(searchState, isTablet),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(HomeSearchState searchState, bool isTablet) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.query.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    if (searchState.searchResults.isEmpty && searchState.query.isNotEmpty) {
      return _buildNoResultsState(isTablet);
    }

    return _buildSearchResults(searchState, isTablet);
  }

  Widget _buildEmptyState(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          HomeRecentSearches(
            onSearchTap: (query) {
              _searchController.text = query;
              _onSearchChanged(query);
            },
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Search Suggestions
          HomeSearchSuggestions(
            onSuggestionTap: (query) {
              _searchController.text = query;
              _onSearchChanged(query);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'No results found',
              style: GoogleFonts.notoSansKr(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textAppBlack,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Try searching with different keywords',
              style: GoogleFonts.notoSansKr(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(HomeSearchState searchState, bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: searchState.searchResults.length,
      itemBuilder: (context, index) {
        final result = searchState.searchResults[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 100 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: HomeSearchResultItem(
            result: result,
            query: searchState.query,
            onTap: () {
              // Add to recent searches
              if (searchState.query.isNotEmpty) {
                ref
                    .read(searchProvider.notifier)
                    .addToRecentSearches(searchState.query);
              }

              // Navigate to product detail or category
              if (result.type == HomeSearchResultType.product) {
                // Debug: Print navigation info
                print('Navigating to product: ${result.id}');
                print('Route: ${RoutePaths.product}/${result.id}');

                // Navigate to product detail
                context.push('${RoutePaths.product}/${result.id}');
              } else if (result.type == HomeSearchResultType.category) {
                // Navigate to search screen with category filter
                print('Navigating to category: ${result.id}');
                print('Category name: ${result.title}');
                context.go(
                  '${RoutePaths.search}?category=${Uri.encodeComponent(result.title)}&categoryId=${result.id}',
                );
              }
            },
          ),
        );
      },
    );
  }
}
