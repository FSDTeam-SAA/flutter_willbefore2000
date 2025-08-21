import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import 'package:smilestreats/feature/home/presentation/screens/home_screach_screen.dart';
import 'package:smilestreats/feature/main/presentation/screens/main_nav_screen.dart';

import '../../feature/auth/presentation/providers/auth_provider.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import '../../feature/cart/presentation/screens/cart_screen.dart';
import '../../feature/home/presentation/screens/home_screen.dart';
import '../../feature/product/presentation/screens/product_detail_screen.dart';
import '../../feature/profile/presentation/screen/profile_screen.dart';
import '../../feature/search/presentation/screens/advance_search_screen.dart';

import '../screens/not_found_screen.dart';
import 'transitions.dart';

part 'app_router.dart';

class RoutePaths {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main navigation routes
  static const String home = '/';
  static const String homeSearch = '/home-search';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String profile = '/profile';

  static const String product = '/product-details';
  static const String productList = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';

  // Error routes
  static const String notFound = '/not-found';
}
