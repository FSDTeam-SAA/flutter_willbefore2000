import 'package:flutter/material.dart';

abstract class BaseController with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Helper method to handle API results consistently
  // void handleApiResult<T>(
  //   ApiResult<T> result, {
  //   required void Function(T? data, String message) onSuccess,
  //   void Function(String message)? onError,
  // }) {
  //   if (result.isSuccess) {
  //     final success = result as ApiSuccess<T>;
  //     onSuccess(success.data, success.message);
  //   } else {
  //     final errorMessage = result.message;
  //     setError(errorMessage);
  //     onError?.call(errorMessage);
  //   }
  // }

  /// Show success message
  // void showSuccess(String message) {
  //   SnackbarService.showSuccess(message);
  // }

  // /// Show error message
  // void showError(String message) {
  //   SnackbarService.showError(message);
  // }

  // /// Show warning message
  // void showWarning(String message) {
  //   SnackbarService.showWarning(message);
  // }

  // /// Show info message
  // void showInfo(String message) {
  //   SnackbarService.showInfo(message);
  // }
}
