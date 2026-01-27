import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../../../product/presentation/providers/products_providers.dart';
import '../../../home/presentation/providers/categories_provider.dart';

enum HomeSearchResultType { product, category }

class HomeSearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final HomeSearchResultType type;
  final double matchScore;

  HomeSearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.type,
    required this.matchScore,
  });
}

class HomeSearchState {
  final String query;
  final List<HomeSearchResult> searchResults;
  final List<String> recentSearches;
  final bool isLoading;
  final String? errorMessage;

  const HomeSearchState({
    this.query = '',
    this.searchResults = const [],
    this.recentSearches = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeSearchState copyWith({
    String? query,
    List<HomeSearchResult>? searchResults,
    List<String>? recentSearches,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeSearchState(
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeSearchNotifier extends StateNotifier<HomeSearchState> {
  final Ref ref;
  static const String _recentSearchesKey = 'recent_searches';

  HomeSearchNotifier(this.ref) : super(const HomeSearchState()) {
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addToRecentSearches(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = List<String>.from(state.recentSearches);

      // Remove if already exists
      recentSearches.remove(query);

      // Add to beginning
      recentSearches.insert(0, query);

      // Keep only last 10 searches
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }

      await prefs.setStringList(_recentSearchesKey, recentSearches);
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      state = state.copyWith(recentSearches: []);
    } catch (e) {
      // Handle error silently
    }
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', searchResults: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, errorMessage: null);

    // Perform fuzzy search
    _performFuzzySearch(query.trim().toLowerCase());
  }

  void _performFuzzySearch(String query) {
    final products = ref.read(productsProvider).products;
    final categories = ref.read(categoriesProvider).categories;

    List<HomeSearchResult> results = [];

    // Search in products
    for (final product in products) {
      final score = _calculateFuzzyScore(query, product.title.toLowerCase());
      if (score > 0.3) {
        results.add(
          HomeSearchResult(
            id: product.id,
            title: product.title,
            subtitle: _stripHtml(product.description),
            imageUrl: product.imageUrls.first,
            type: HomeSearchResultType.product,
            matchScore: score,
          ),
        );
      }
    }

    // Search in categories
    for (final category in categories) {
      final score = _calculateFuzzyScore(query, category.name.toLowerCase());
      if (score > 0.3) {
        results.add(
          HomeSearchResult(
            id: category.id,
            title: category.name,
            subtitle: 'Category',
            imageUrl: category.imageUrl,
            type: HomeSearchResultType.category,
            matchScore: score,
          ),
        );
      }
    }

    // Sort by match score (highest first)
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    state = state.copyWith(searchResults: results, isLoading: false);
  }

  double _calculateFuzzyScore(String query, String target) {
    if (target.contains(query)) {
      // Exact substring match gets high score
      return 0.9 + (query.length / target.length) * 0.1;
    }

    // Calculate Levenshtein distance based similarity
    final distance = _levenshteinDistance(query, target);
    final maxLength = query.length > target.length
        ? query.length
        : target.length;

    if (maxLength == 0) return 1.0;

    final similarity = 1.0 - (distance / maxLength);

    // Boost score if query words are found in target
    final queryWords = query.split(' ');
    final targetWords = target.split(' ');
    int wordMatches = 0;

    for (final queryWord in queryWords) {
      for (final targetWord in targetWords) {
        if (targetWord.contains(queryWord) || queryWord.contains(targetWord)) {
          wordMatches++;
          break;
        }
      }
    }

    final wordMatchBonus = wordMatches / queryWords.length * 0.3;

    return similarity + wordMatchBonus;
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  String _stripHtml(String htmlString) {
    // Remove HTML tags
    String text = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  void clearSearch() {
    state = state.copyWith(
      query: '',
      searchResults: [],
      isLoading: false,
      errorMessage: null,
    );
  }
}

final searchProvider =
    StateNotifierProvider<HomeSearchNotifier, HomeSearchState>((ref) {
      return HomeSearchNotifier(ref);
    });
