import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchFilterState {
  final String selectedCategory;
  final String selectedCategoryId; // Add category ID
  final RangeValues priceRange;
  final Set<int> selectedRatings;
  final Set<String> selectedBrands;

  const SearchFilterState({
    this.selectedCategory = 'All',
    this.selectedCategoryId = '',
    this.priceRange = const RangeValues(0, 1000),
    this.selectedRatings = const {},
    this.selectedBrands = const {},
  });

  SearchFilterState copyWith({
    String? selectedCategory,
    String? selectedCategoryId,
    RangeValues? priceRange,
    Set<int>? selectedRatings,
    Set<String>? selectedBrands,
  }) {
    return SearchFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      priceRange: priceRange ?? this.priceRange,
      selectedRatings: selectedRatings ?? this.selectedRatings,
      selectedBrands: selectedBrands ?? this.selectedBrands,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(const SearchFilterState());

  void updateCategory(String category, {String? categoryId}) {
    state = state.copyWith(
      selectedCategory: category,
      selectedCategoryId: categoryId ?? '',
    );
  }

  void updatePriceRange(RangeValues priceRange) {
    state = state.copyWith(priceRange: priceRange);
  }

  void toggleRating(int rating) {
    final newRatings = Set<int>.from(state.selectedRatings);
    if (newRatings.contains(rating)) {
      newRatings.remove(rating);
    } else {
      newRatings.add(rating);
    }
    state = state.copyWith(selectedRatings: newRatings);
  }

  void toggleBrand(String brand) {
    final newBrands = Set<String>.from(state.selectedBrands);
    if (newBrands.contains(brand)) {
      newBrands.remove(brand);
    } else {
      newBrands.add(brand);
    }
    state = state.copyWith(selectedBrands: newBrands);
  }

  void resetFilters() {
    state = const SearchFilterState();
  }
}

final searchFilterProvider =
    StateNotifierProvider.autoDispose<SearchFilterNotifier, SearchFilterState>(
      (ref) => SearchFilterNotifier(),
    );
