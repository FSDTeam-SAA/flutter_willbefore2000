import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_state.dart';

abstract class BaseController extends StateNotifier<BaseState> {

  BaseController(BaseState baseState) : super(const BaseState());

  bool get isLoading => state.isLoading;
  String get errorMessage => state.errorMessage;

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}
