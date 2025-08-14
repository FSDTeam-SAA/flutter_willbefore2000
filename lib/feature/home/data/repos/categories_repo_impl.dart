import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/category_model.dart';
import '../../domain/repos/categories_repo.dart';
import '../sources/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Stream<List<CategoryModel>> getCategoriesStream() {
    return remoteDataSource.getCategoriesStream();
  }
}

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final remoteDataSource = CategoriesRemoteDataSource(
    FirebaseFirestore.instance,
  );
  return CategoriesRepositoryImpl(remoteDataSource);
});
