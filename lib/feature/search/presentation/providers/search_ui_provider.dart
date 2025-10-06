import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchUIProvider = StateNotifierProvider.autoDispose<SearchUINotifier, SearchUIState>((ref) {
  return SearchUINotifier();
});

class SearchUIState {
  final bool showSuggestions;
  final bool isLoadingMore;

  const SearchUIState({
    this.showSuggestions = false,
    this.isLoadingMore = false,
  });

  SearchUIState copyWith({
    bool? showSuggestions,
    bool? isLoadingMore,
  }) {
    return SearchUIState(
      showSuggestions: showSuggestions ?? this.showSuggestions,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchUINotifier extends StateNotifier<SearchUIState> {
  SearchUINotifier() : super(const SearchUIState());

  void showSuggestions() {
    state = state.copyWith(showSuggestions: true);
  }

  void hideSuggestions() {
    state = state.copyWith(showSuggestions: false);
  }

  void updateLoadingMore(bool loading) {
    state = state.copyWith(isLoadingMore: loading);
  }
}