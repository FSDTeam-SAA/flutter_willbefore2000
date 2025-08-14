class BaseState {
  final bool isLoading;
  final String errorMessage;

  const BaseState({
    this.isLoading = false,
    this.errorMessage = '',
  });

  BaseState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return BaseState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}