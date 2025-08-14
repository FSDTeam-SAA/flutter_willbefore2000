import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base/base_state.dart';
import '../../data/repos/categories_repo_impl.dart';
import '../../domain/models/category_model.dart';

import '../../domain/usercases/get_category_use_case.dart';

class CategoriesState extends BaseState {
  final List<CategoryModel> categories;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const CategoriesState({
    super.isLoading = false,
    super.errorMessage,
    this.categories = const [],
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  @override
  CategoriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CategoryModel>? categories,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesProvider, CategoriesState>((ref) {
      final repository = ref.watch(categoriesRepositoryProvider);
      final getCategoriesUseCase = GetCategoriesUseCase(repository);

      return CategoriesProvider(getCategoriesUseCase);
    });

class CategoriesProvider extends StateNotifier<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesProvider(this._getCategoriesUseCase)
    : super(const CategoriesState()) {
    fetchCategories();
    _listenToCategories();
  }

  void _listenToCategories() {
    _getCategoriesUseCase.stream().listen(
      (categories) {
        state = state.copyWith(categories: categories, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await _getCategoriesUseCase.call();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
