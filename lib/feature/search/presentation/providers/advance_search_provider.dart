import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fuzzy_search.dart';
import '../../../product/domain/entrity/product.dart';
import '../../../product/presentation/providers/products_providers.dart';

final advancedSearchProvider = StateNotifierProvider<AdvancedSearchNotifier, AdvancedSearchState>((ref) {
  return AdvancedSearchNotifier(ref);
});

class AdvancedSearchState {
  final List<Product> products;
  final List<Product> allProducts;
  final List<String> searchHistory;
  final List<String> popularSearches;
  final String searchQuery;
  final String selectedCategory;
  final String sortBy;
  final double minPrice;
  final double maxPrice;
  final bool isLoading;
  final int currentPage;
  final int totalResults;
  final bool hasMoreData;
  final bool isSearchMode;

  const AdvancedSearchState({
    this.products = const [],
    this.allProducts = const [],
    this.searchHistory = const [],
    this.popularSearches = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.sortBy = 'relevance',
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalResults = 0,
    this.hasMoreData = true,
    this.isSearchMode = false,
  });

  AdvancedSearchState copyWith({
    List<Product>? products,
    List<Product>? allProducts,
    List<String>? searchHistory,
    List<String>? popularSearches,
    String? searchQuery,
    String? selectedCategory,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    bool? isLoading,
    int? currentPage,
    int? totalResults,
    bool? hasMoreData,
    bool? isSearchMode,
  }) {
    return AdvancedSearchState(
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      searchHistory: searchHistory ?? this.searchHistory,
      popularSearches: popularSearches ?? this.popularSearches,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isSearchMode: isSearchMode ?? this.isSearchMode,
    );
  }
}

class AdvancedSearchNotifier extends StateNotifier<AdvancedSearchState> {
  final Ref ref;
  static const int _pageSize = 20;

  AdvancedSearchNotifier(this.ref) : super(const AdvancedSearchState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    
    final productsState = ref.read(productsProvider);
    await ref.read(productsProvider.notifier).fetchProducts();
    
    // final searchHistory = await _loadSearchHistory();
    final popularSearches = await _loadPopularSearches();
    
    final allProducts = productsState.products;
    final filteredProducts = _applyFiltersAndSort(allProducts);
    final initialProducts = _paginateResults(filteredProducts, 1);
    
    state = state.copyWith(
      allProducts: allProducts,
      products: initialProducts,
      // searchHistory: searchHistory,
      popularSearches: popularSearches,
      totalResults: filteredProducts.length,
      hasMoreData: filteredProducts.length > _pageSize,
      isLoading: false,
      isSearchMode: false,
    );
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      currentPage: 1,
      isSearchMode: true,
    );

    final fuzzySearch = FuzzySearch(state.allProducts);
    final searchResults = fuzzySearch.search(query);
    
    final filteredResults = _applyFiltersAndSort(searchResults);
    
    final paginatedResults = _paginateResults(filteredResults, 1);
    
    state = state.copyWith(
      products: paginatedResults,
      totalResults: filteredResults.length,
      hasMoreData: filteredResults.length > _pageSize,
      isLoading: false,
    );
  }

  Future<void> loadMoreProducts() async {
    if (!state.hasMoreData || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    List<Product> filteredResults;
    
    if (state.isSearchMode) {
      final fuzzySearch = FuzzySearch(state.allProducts);
      final searchResults = fuzzySearch.search(state.searchQuery);
      filteredResults = _applyFiltersAndSort(searchResults);
    } else {
      filteredResults = _applyFiltersAndSort(state.allProducts);
    }
    
    final newProducts = _paginateResults(filteredResults, nextPage);
    
    if (newProducts.isNotEmpty) {
      state = state.copyWith(
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasMoreData: filteredResults.length > nextPage * _pageSize,
      );
    } else {
      state = state.copyWith(hasMoreData: false);
    }
  }

  void updateFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
  }) {
    state = state.copyWith(
      selectedCategory: category ?? state.selectedCategory,
      minPrice: minPrice ?? state.minPrice,
      maxPrice: maxPrice ?? state.maxPrice,
      currentPage: 1,
    );
    
    if (state.isSearchMode) {
      searchProducts(state.searchQuery);
    } else {
      _loadAllProductsWithFilters();
    }
  }

  void updateSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy, currentPage: 1);
    
    if (state.isSearchMode) {
      searchProducts(state.searchQuery);
    } else {
      _loadAllProductsWithFilters();
    }
  }

  void clearSearch() {
    _loadAllProductsWithFilters();
    state = state.copyWith(
      searchQuery: '',
      isSearchMode: false,
    );
  }

  void _loadAllProductsWithFilters() {
    final filteredProducts = _applyFiltersAndSort(state.allProducts);
    final paginatedProducts = _paginateResults(filteredProducts, 1);
    
    state = state.copyWith(
      products: paginatedProducts,
      currentPage: 1,
      totalResults: filteredProducts.length,
      hasMoreData: filteredProducts.length > _pageSize,
      isSearchMode: false,
    );
  }

  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    // final prefs = await SharedPreferences.getInstance();
    final history = state.searchHistory.toList();
    
    history.remove(query);
    history.insert(0, query);
    
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    // await prefs.setStringList('search_history', history);
    state = state.copyWith(searchHistory: history);
  }

  List<Product> _applyFiltersAndSort(List<Product> products) {
    var filtered = products.where((product) {
      if (state.selectedCategory != 'All' && 
          product.categoryId != state.selectedCategory) {
        return false;
      }
      
      if (product.effectivePrice < state.minPrice || 
          product.effectivePrice > state.maxPrice) {
        return false;
      }
      
      return true;
    }).toList();

    switch (state.sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      // case 'rating':
      //   filtered.sort((a, b) => b.rating.compareTo(a.rating));
      //   break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'relevance':
      default:
        break;
    }

    return filtered;
  }

  List<Product> _paginateResults(List<Product> products, int page) {
    final startIndex = (page - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    if (startIndex >= products.length) return [];
    
    return products.sublist(
      startIndex,
      endIndex > products.length ? products.length : endIndex,
    );
  }

  // Future<List<String>> _loadSearchHistory() async {
  //   // final prefs = await SharedPreferences.getInstance();
  //   return prefs.getStringList('search_history') ?? [];
  // }

  Future<List<String>> _loadPopularSearches() async {
    return [
      'iPhone',
      'Samsung Galaxy',
      'Nike Shoes',
      'Laptop',
      'Headphones',
      'Watch',
      'Camera',
      'Books',
    ];
  }
}
