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

  void updateShowSuggestions(bool show) {
    state = state.copyWith(showSuggestions: show);
  }

  void updateLoadingMore(bool loading) {
    state = state.copyWith(isLoadingMore: loading);
  }

  void hideSuggestions() {
    state = state.copyWith(showSuggestions: false);
  }
}
