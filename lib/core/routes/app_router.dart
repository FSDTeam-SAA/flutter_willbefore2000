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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final container = ProviderScope.containerOf(context);
      final authGuard = container.read(authGuardProvider);

      // Wait for auth to initialize
      if (!authGuard.isInitialized) return null;

      // final isLoginRoute = state.matchedLocation == RouteEndpoint.login;
      final isAuthRoute = [
        RoutePaths.login,
        RoutePaths.signup,
        RoutePaths.forgotPassword,
      ].contains(state.matchedLocation);

      // If not authenticated and trying to access protected route
      if (!authGuard.isAuthenticated && !isAuthRoute) {
        return RoutePaths.login;
      }

      // If authenticated and trying to access auth route
      if (authGuard.isAuthenticated && isAuthRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
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
      // GoRoute(
      //   path: RouteEndpoint.signup,
      //   name: RouteEndpoint.signup,
      //   pageBuilder: (context, state) => buildPageWithDefaultTransition(
      //     context: context,
      //     child: const SignupScreen(), state: state,
      //   ),
      // ),
      // GoRoute(
      //   path: RouteEndpoint.forgotPassword,
      //   name: RouteEndpoint.forgotPassword,
      //   pageBuilder: (context, state) => buildPageWithDefaultTransition(
      //     context: context,
      //     child: const ForgotPasswordScreen(),
      //   ),
      // ),

      // Main app shell
      ShellRoute(
        builder: (context, state, child) => MainNavScreen(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const HomeScreen(),
            //   state: state,
            // ),
          ),
          GoRoute(
            path: RoutePaths.search,
            name: RoutePaths.search,
            builder: (context, state) => const SearchScreen(),
            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const SearchScreen(),
            //   state: state,
            // ),
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
            // pageBuilder: (context, state) => AppTransitions.slideTransition(
            //   context: context,
            //   child: const ProfileScreen(),
            //   state: state,
            // ),
          ),
        ],
      ),

      GoRoute(
        path: '${RoutePaths.product}/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
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
      // GoRoute(
      //   path: RoutePaths.categories,
      //   name: 'categories',
      //   builder: (context, state) => const CategoriesScreen(),
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
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
      state: state,
    ),
  );
}
