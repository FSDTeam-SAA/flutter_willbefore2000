import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../providers/advance_search_provider.dart';
import '../widgets/search_filter_drawer.dart';
import '../widgets/category_chips.dart';
import '../widgets/search_suggestions_overlay.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _showSuggestions = false;
  bool _isLoadingMore = false;

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
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && _searchController.text.isEmpty;
    });
  }

  void _loadMoreProducts() {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      ref.read(advancedSearchProvider.notifier).loadMoreProducts().then((_) {
        if (mounted) setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(advancedSearchProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      endDrawer: const SearchFilterDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchHeader(),
                if (!_showSuggestions) _buildCategorySection(),
                Expanded(child: _buildSearchResults(searchState)),
              ],
            ),
            if (_showSuggestions)
              SearchSuggestionsOverlay(
                onSuggestionTap: _onSuggestionTap,
                onDismiss: () => setState(() => _showSuggestions = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: AppColors.textAppBlack,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _searchFocusNode.hasFocus 
                          ? AppColors.primaryLaurel 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
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
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
            DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
            DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
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
    return Container(
      height: 50,
      color: Colors.white,
      child: const CategoryChips(),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
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
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = searchState.products[index];
                final heroTag = HeroTagManager.forSearchResults(
                  product.id,
                  index,
                );
                return ProductCard(
                  product: product,
                  heroTag: heroTag,
                );
              },
              childCount: searchState.products.length,
            ),
          ),
        ),
        if (_isLoadingMore)
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
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
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
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Clear Search',
              style: GoogleFonts.notoSansKr(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _showSuggestions = query.isEmpty && _searchFocusNode.hasFocus;
    });
    
    if (query.isNotEmpty) {
      ref.read(advancedSearchProvider.notifier).searchProducts(query);
    } else {
      ref.read(advancedSearchProvider.notifier).clearSearch();
    }
  }

  void _onSearchSubmitted(String query) {
    _searchFocusNode.unfocus();
    setState(() => _showSuggestions = false);
    ref.read(advancedSearchProvider.notifier).addToSearchHistory(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(advancedSearchProvider.notifier).clearSearch();
    setState(() => _showSuggestions = false);
  }
}
