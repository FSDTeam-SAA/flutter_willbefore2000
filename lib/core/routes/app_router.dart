part of 'route_endpoint.dart';

final authGuardProvider = Provider<AuthGuardState>((ref) {
  final authState = ref.watch(authProvider);
  return AuthGuardState(
    isAuthenticated: authState.isAuthenticated,
    isInitialized: authState.isInitialized,
  );
});

class AuthGuardState {
  final bool isAuthenticated;
  final bool isInitialized;

  AuthGuardState({required this.isAuthenticated, required this.isInitialized});
}

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isInitialized != next.isInitialized) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: listenable,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authGuard = ref.read(authGuardProvider);

      // Wait for auth to initialize
      if (!authGuard.isInitialized) return null;

      final isAuthRoute = [
        RoutePaths.login,
        RoutePaths.signup,
        RoutePaths.forgotPassword,
      ].contains(state.matchedLocation);

      // If not authenticated and trying to access protected route
      if (!authGuard.isAuthenticated &&
          !isAuthRoute &&
          state.matchedLocation != RoutePaths.splash) {
        return RoutePaths.login;
      }

      // If authenticated and trying to access auth route
      if (authGuard.isAuthenticated && isAuthRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RoutePaths.splash,
        pageBuilder: (context, state) => AppTransitions.fadeSlideTransition(
          context: context,
          child: const SplashScreen(),
          state: state,
        ),
      ),

      // Auth routes
      GoRoute(
        path: RoutePaths.login,
        name: RoutePaths.login,
        pageBuilder: (context, state) => AppTransitions.fadeSlideTransition(
          context: context,
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RoutePaths.signup,
        pageBuilder: (context, state) => AppTransitions.slideTransition(
          context: context,
          child: const SignupScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RoutePaths.forgotPassword,
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';

          return AppTransitions.slideTransition(
            context: context,
            child: ForgotPasswordScreen(email: email),
            state: state,
          );
        },
      ),

      // Main app shell
      ShellRoute(
        builder: (context, state, child) => MainNavScreen(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: "Home",
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: RoutePaths.categories,
                name: RoutePaths.categories,
                builder: (context, state) => const CategoriesView(),
              ),
              GoRoute(
                path: RoutePaths.notification,
                name: RoutePaths.notification,
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const HomeScreen(),
            //   state: state,
            // ),
          ),
          GoRoute(
            path: RoutePaths.search,
            name: "Search",
            pageBuilder: (context, state) {
              // Extract query parameters for category filtering
              final category = state.uri.queryParameters['category'];
              final categoryId = state.uri.queryParameters['categoryId'];

              return MaterialPage(
                key: state.pageKey,
                child: AdvancedSearchScreen(
                  initialCategory: category,
                  initialCategoryId: categoryId,
                ),
              );
            },
          ),
          GoRoute(
            path: RoutePaths.cart,
            name: RoutePaths.cart,
            builder: (context, state) => const CartScreen(),

            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const CartScreen(),
            //   state: state,
            // ),
          ),

          GoRoute(
            path: RoutePaths.profile,
            name: RoutePaths.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'personal-info', // Relative path
                name: RoutePaths.personalInfoName, // Route name
                builder: (context, state) => const PersonalInfoScreen(),
              ),
              GoRoute(
                path: 'personal-info-edit',
                name: RoutePaths.editProfile,
                builder: (context, state) => const EditPersonalInfoScreen(),
              ),

              GoRoute(
                path: 'change-password',
                name: RoutePaths.changePassword,
                builder: (context, state) => const ChangePasswordScreen(),
              ),

              GoRoute(
                path: 'privacy-policy',
                name: RoutePaths.appPrivacyPolicy,
                builder: (context, state) => const PrivacyPolicyScreen(),
              ),

              GoRoute(
                path: 'terms-and-conditions',
                name: RoutePaths.appTermsAndConditions,
                builder: (context, state) => const TermsAndConditionsScreen(),
              ),
            ],
            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const ProfileScreen(),
            //   state: state,
            // ),
          ),
        ],
      ),

      GoRoute(
        path: RoutePaths.orders,
        name: RoutePaths.orders,
        pageBuilder: (context, state) {
          return AppTransitions.slideTransition(
            child: const OrdersScreen(),
            context: context,
            state: state,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.orderConfirm,
        name: RoutePaths.orderConfirm,
        pageBuilder: (context, state) {
          final order = state.extra as Order;

          return AppTransitions.slideTransition(
            child: OrderConfirmationScreen(order: order),
            context: context,
            state: state,
          );
        },
      ),

      GoRoute(
        path: RoutePaths.checkout,
        name: RoutePaths.checkout,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final buyNowItem = extra != null
              ? extra['buyNowItem'] as CartItem?
              : null;

          return AppTransitions.slideTransition(
            child: CheckoutScreen(buyNowItem: buyNowItem),
            context: context,
            state: state,
          );
        },
      ),

      GoRoute(
        path: '${RoutePaths.product}/:productId',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final heroTag =
              state.extra as String?; // Get Hero tag from extra data

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: ProductDetailScreen(
              productId: productId,
              heroTag: heroTag, // Pass Hero tag to product detail screen
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      // GoRoute(
      //   path: '${RoutePaths.productList}/:type',
      //   name: 'product-list',
      //   builder: (context, state) {
      //     final type = state.pathParameters['type']!;
      //     final title = state.uri.queryParameters['title'] ?? type;
      //     return ProductListScreen(type: type, title: title);
      //   },
      // ),
      GoRoute(
        path: RoutePaths.homeSearch,
        name: 'home-search',
        builder: (context, state) {
          return HomeSearchScreen();
        },
      ),
      // GoRoute(
      //   path: RoutePaths.categories,
      //   name: RoutePaths.categories,
      //   builder: (context, state) => const CategoryShows(),
      // ),
      // GoRoute(
      //   path: RoutePaths.orders,
      //   name: 'orders',
      //   builder: (context, state) => const OrdersScreen(),
      // ),

      // Error route
      GoRoute(
        path: RoutePaths.notFound,
        name: RoutePaths.notFound,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          child: const NotFoundScreen(),
          state: state,
        ),
      ),
    ],
    errorPageBuilder: (context, state) => buildPageWithDefaultTransition(
      context: context,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              context.primaryButton(
                // isLoading: authState.isLoading,
                onPressed: () => GoRouter.of(context).go(RoutePaths.home),
                text: "Go to Dashboard",
              ),
            ],
          ),
        ),
      ),
      state: state,
    ),
  );
});
