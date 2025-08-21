import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
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
  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(advancedSearchProvider);
    final uiState = ref.watch(searchUIProvider);
    
    return _AdvancedSearchView(
      searchState: searchState,
      uiState: uiState,
    );
  }
}

class _AdvancedSearchView extends ConsumerStatefulWidget {
  final AdvancedSearchState searchState;
  final SearchUIState uiState;

  const _AdvancedSearchView({
    required this.searchState,
    required this.uiState,
  });

  @override
  ConsumerState<_AdvancedSearchView> createState() => _AdvancedSearchViewState();
}

class _AdvancedSearchViewState extends ConsumerState<_AdvancedSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(advancedSearchProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _onFocusChange() {
    ref.read(searchUIProvider.notifier).updateShowSuggestions(
      _searchFocusNode.hasFocus && _searchController.text.isEmpty,
    );
  }

  void _loadMoreProducts() {
    final uiState = ref.read(searchUIProvider);
    if (!uiState.isLoadingMore) {
      ref.read(searchUIProvider.notifier).updateLoadingMore(true);
      ref.read(advancedSearchProvider.notifier).loadMoreProducts().then((_) {
        if (mounted) {
          ref.read(searchUIProvider.notifier).updateLoadingMore(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  if (!widget.uiState.showSuggestions) _buildCategorySection(),
                  Expanded(child: _buildSearchResults(widget.searchState)),
                ],
              ),
              if (widget.uiState.showSuggestions)
                SearchSuggestionsOverlay(
                  onSuggestionTap: _onSuggestionTap,
                  onDismiss: () => ref.read(searchUIProvider.notifier).hideSuggestions(),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(),
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSearchStats(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchStats() {
    final searchState = ref.watch(advancedSearchProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${searchState.totalResults} results found',
          style: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
        DropdownButton<String>(
          value: searchState.sortBy,
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
            DropdownMenuItem(value: 'rating', child: Text('Rating')),
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
    return SizedBox(
      height: 50,
      child: const CategoryChips(),
    );
  }

  Widget _menuBar() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Menu".text16w700(),
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

  Widget _buildSearchResults(AdvancedSearchState searchState) {
    if (searchState.isLoading && searchState.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.products.isEmpty && searchState.isSearchMode) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                searchState.isSearchMode
                    ? 'Search Results (${searchState.totalResults})'
                    : 'All Products (${searchState.totalResults})',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textAppBlack,
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
            final heroTag = HeroTagManager.forSearchResults(product.id, index);
            return ProductCard(
              product: product,
              heroTag: heroTag,
              isHorizontal: true,
            );
          }, childCount: searchState.products.length),
        ),
        if (widget.uiState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
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
            'No products found',
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textAppBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or check filters',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          context.primaryButton(onPressed: _clearSearch, text: "Clear Search"),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    ref.read(searchUIProvider.notifier).updateShowSuggestions(
      query.isEmpty && _searchFocusNode.hasFocus,
    );

    if (query.isNotEmpty) {
      ref.read(advancedSearchProvider.notifier).searchProducts(query);
    } else {
      ref.read(advancedSearchProvider.notifier).clearSearch();
    }
  }

  void _onSearchSubmitted(String query) {
    _searchFocusNode.unfocus();
    ref.read(searchUIProvider.notifier).hideSuggestions();
    ref.read(advancedSearchProvider.notifier).addToSearchHistory(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(advancedSearchProvider.notifier).clearSearch();
    ref.read(searchUIProvider.notifier).hideSuggestions();
  }
}
