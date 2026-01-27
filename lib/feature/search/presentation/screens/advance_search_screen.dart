import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../providers/advance_search_provider.dart';
import '../providers/search_ui_provider.dart';
import '../widgets/search_filter_drawer.dart';
import '../widgets/category_chips.dart';
import '../widgets/search_suggestions_overlay.dart';

class AdvancedSearchScreen extends ConsumerWidget {
  final String? initialCategory;
  final String? initialCategoryId;

  const AdvancedSearchScreen({
    super.key,
    this.initialCategory,
    this.initialCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(advancedSearchProvider);
    final uiState = ref.watch(searchUIProvider);

    return _AdvancedSearchView(
      searchState: searchState,
      uiState: uiState,
      initialCategory: initialCategory,
      initialCategoryId: initialCategoryId,
    );
  }
}

class _AdvancedSearchView extends ConsumerStatefulWidget {
  final AdvancedSearchState searchState;
  final SearchUIState uiState;
  final String? initialCategory;
  final String? initialCategoryId;

  const _AdvancedSearchView({
    required this.searchState,
    required this.uiState,
    this.initialCategory,
    this.initialCategoryId,
  });

  @override
  ConsumerState<_AdvancedSearchView> createState() =>
      _AdvancedSearchViewState();
}

class _AdvancedSearchViewState extends ConsumerState<_AdvancedSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _lastChange = DateTime.now();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Apply initial category filter BEFORE loading data
      if (widget.initialCategory != null || widget.initialCategoryId != null) {
        // Set the filter state first using the proper method
        ref
            .read(advancedSearchProvider.notifier)
            .setInitialFilters(
              category: widget.initialCategory ?? 'All',
              categoryId: widget.initialCategoryId ?? '',
            );
      }

      // Now load the data with filters already set
      ref.read(advancedSearchProvider.notifier).loadInitialData();
    });
  }

  @override
  void didUpdateWidget(covariant _AdvancedSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller with state when search query changes externally
    if (widget.searchState.searchQuery != _searchController.text) {
      _searchController.text = widget.searchState.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      ref.read(searchUIProvider.notifier).showSuggestions();
    } else {
      ref.read(searchUIProvider.notifier).hideSuggestions();
    }
  }

  Future<void> _loadMoreProducts() async {
    final searchState = ref.read(advancedSearchProvider);
    final uiState = ref.read(searchUIProvider);

    if (!searchState.hasMoreData ||
        searchState.isLoadingMore ||
        uiState.isLoadingMore) {
      return;
    }

    ref.read(searchUIProvider.notifier).updateLoadingMore(true);
    await ref.read(advancedSearchProvider.notifier).loadMoreProducts();
    if (mounted) {
      ref.read(searchUIProvider.notifier).updateLoadingMore(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const SearchFilterDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildSearchHeader(),
                    _menuBar(),
                    if (!widget.uiState.showSuggestions)
                      _buildCategorySection(),
                    Expanded(child: _buildSearchResults()),
                  ],
                ),
                if (widget.uiState.showSuggestions)
                  SearchSuggestionsOverlay(
                    onSuggestionTap: _onSuggestionTap,
                    onDismiss: () =>
                        ref.read(searchUIProvider.notifier).hideSuggestions(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search for products, brands, categories...',
                  hintStyle: GoogleFonts.notoSansKr(
                    color: AppColors.textSecondaryHintColor,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondaryHintColor,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondaryHintColor,
                            size: 20,
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryLaurel),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter button moved to menu bar
          ],
        ),
        if (_searchController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSearchStats(),
        ],
      ],
    );
  }

  Widget _buildSearchStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.searchState.totalResults} results found',
          style: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
        DropdownButton<String>(
          value: widget.searchState.sortBy,
          underline: const SizedBox(),
          style: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: AppColors.textAppBlack,
          ),
          items: const [
            DropdownMenuItem(value: 'relevance', child: Text('Relevance')),
            DropdownMenuItem(
              value: 'price_low',
              child: Text('Price: Low to High'),
            ),
            DropdownMenuItem(
              value: 'price_high',
              child: Text('Price: High to Low'),
            ),
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(advancedSearchProvider.notifier).updateSortBy(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return const SizedBox(height: 50, child: CategoryChips());
  }

  Widget _menuBar() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Menu",
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textAppBlack,
            ),
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.tune),
            color: AppColors.primaryLaurel,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, child) {
        final searchState = ref.watch(advancedSearchProvider);
        final uiState = ref.watch(searchUIProvider);

        if (searchState.isLoading && searchState.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchState.products.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      searchState.isSearchMode
                          ? 'Search Results (${searchState.totalResults})'
                          : 'All Products (${searchState.totalResults})',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textAppBlack,
                      ),
                    ),
                  ),
                  if (searchState.isSearchMode)
                    TextButton(
                      onPressed: _clearSearch,
                      child: Text(
                        'View All',
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.primaryLaurel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = searchState.products[index];
                final heroTag = HeroTagManager.forSearchResults(
                  product.id,
                  index,
                );
                return ProductCard(
                  product: product,
                  heroTag: heroTag,
                  isHorizontal: true,
                );
              }, childCount: searchState.products.length),
            ),

            // Loading more indicator
            if (searchState.isLoadingMore || uiState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // End of list indicator
            if (!searchState.hasMoreData && searchState.products.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No more products',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.searchState.isSearchMode
                ? 'No products found'
                : 'No products available',
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textAppBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.searchState.isSearchMode
                ? 'Try different keywords or check filters'
                : 'Check back later for new products',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.searchState.isSearchMode)
            context.primaryButton(onPressed: _clearSearch, text: "Clear Search")
          else
            context.primaryButton(
              onPressed: () =>
                  ref.read(advancedSearchProvider.notifier).loadInitialData(),
              text: "Refresh",
            ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    final now = DateTime.now();
    if (now.difference(_lastChange).inMilliseconds < 100) {
      return; // Throttle to 100ms
    }
    _lastChange = now;

    final currentShowSuggestions = ref.read(searchUIProvider).showSuggestions;

    if (query.isEmpty && _searchFocusNode.hasFocus && !currentShowSuggestions) {
      ref.read(searchUIProvider.notifier).showSuggestions();
    } else if (!query.isEmpty && currentShowSuggestions) {
      ref.read(searchUIProvider.notifier).hideSuggestions();
    }

    if (query.isNotEmpty) {
      _debouncedSearch(query);
    } else {
      ref.read(advancedSearchProvider.notifier).clearSearch();
    }
  }

  void _onSearchSubmitted(String query) {
    _searchFocusNode.unfocus();
    ref.read(searchUIProvider.notifier).hideSuggestions();
    if (query.isNotEmpty) {
      ref.read(advancedSearchProvider.notifier).addToSearchHistory(query);
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    ref.read(searchUIProvider.notifier).hideSuggestions();
    ref.read(advancedSearchProvider.notifier).searchProducts(suggestion);
    ref.read(advancedSearchProvider.notifier).addToSearchHistory(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(advancedSearchProvider.notifier).clearSearch();
    ref.read(searchUIProvider.notifier).hideSuggestions();
  }

  // Debounce search to avoid too many API calls
  void _debouncedSearch(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(advancedSearchProvider.notifier).searchProducts(query);
    });
  }
}
