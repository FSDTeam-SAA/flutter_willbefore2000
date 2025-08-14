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
    initialLocation: RouteEndpoint.home,

    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authGuard = container.read(authGuardProvider);

      final isLoginRoute = state.matchedLocation == RouteEndpoint.login;

      // If not authenticated and trying to access proteced route
      if (!authGuard.isAuthenticated && !isLoginRoute) {
        return RouteEndpoint.login;
      }

      // If authenticated and on loing page, redirect to dashboard
      if (authGuard.isAuthenticated && isLoginRoute) {
        return RouteEndpoint.home;
      }

      return null;
    },



    routes: [
      GoRoute(
        path: RouteEndpoint.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        // pageBuilder: (context, state) => CustomTransitionPage(child: , transitionsBuilder: transitionsBuilder),
      ),

      // GoRoute(
      //   path: '/signup',
      //   name: 'signup',
      //   builder: (context, state) => const SignupScreen(),
      // ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RouteEndpoint.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            // pageBuilder: (context, state) => CustomTransitionPage(
            //   key: state.pageKey,
            //   child: const HomeScreen(),
            //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //     return slideTransition(child).transitionsBuilder!(
            //       context, 
            //       animation, 
            //       secondaryAnimation, 
            //       child
            //     );
            //   },
            // ),
          ),
          GoRoute(
            path: RouteEndpoint.search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteEndpoint.cart,
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteEndpoint.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
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
              onPressed: () => context.go(RouteEndpoint.home),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
