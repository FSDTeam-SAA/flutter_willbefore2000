import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Filter state class
class SearchFilterState {
  final String selectedCategory;
  final RangeValues priceRange;
  final Set<int> selectedRatings;
  final Set<String> selectedBrands;

  const SearchFilterState({
    this.selectedCategory = 'All',
    this.priceRange = const RangeValues(0, 1000),
    this.selectedRatings = const {},
    this.selectedBrands = const {},
  });

  SearchFilterState copyWith({
    String? selectedCategory,
    RangeValues? priceRange,
    Set<int>? selectedRatings,
    Set<String>? selectedBrands,
  }) {
    return SearchFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      priceRange: priceRange ?? this.priceRange,
      selectedRatings: selectedRatings ?? this.selectedRatings,
      selectedBrands: selectedBrands ?? this.selectedBrands,
    );
  }
}

// Filter state notifier
class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(const SearchFilterState());

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
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

// Provider
final searchFilterProvider =
    StateNotifierProvider.autoDispose<SearchFilterNotifier, SearchFilterState>(
      (ref) => SearchFilterNotifier(),
    );
