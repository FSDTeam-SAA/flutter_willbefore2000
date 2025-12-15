import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repos/products_repository_impl.dart';
import '../../data/sources/products_remote_data_source.dart';
import '../../domain/entrity/product.dart';
import '../../../home/domain/usercases/get_products_use_case.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final GetProductsUseCase _getProductsUseCase;

  ProductsNotifier(this._getProductsUseCase) : super(const ProductsState()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await _getProductsUseCase.call();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Products Provider with direct dependency creation
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    // Create dependencies directly
    final firestore = FirebaseFirestore.instance;

    final remoteDataSource = ProductsRemoteDataSourceImpl(firestore);
    final repository = ProductsRepositoryImpl(remoteDataSource);

    final getProductsUseCase = GetProductsUseCase(repository);

    return ProductsNotifier(getProductsUseCase);
  },
);
