import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/home_dashboard_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/saved_trips/screens/saved_trips_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/trip_setup/screens/trip_setup_screen.dart';
import '../../features/itinerary/screens/itinerary_screen.dart';
import '../../features/route_optimization/screens/route_optimization_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/place_details/screens/place_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.state;
      final path = state.uri.path;

      final isLoading = authState.status == AuthStatus.loading;
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (isLoading) return path == '/splash' ? null : '/splash';

      final onAuthScreen = path == '/login' || path == '/register';

      if (!isAuthenticated && !onAuthScreen) return '/login';
      if (isAuthenticated && (onAuthScreen || path == '/splash')) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedTripsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Feature screens (pushed on top of shell)
      GoRoute(
        path: '/trip-setup',
        builder: (context, state) => const TripSetupScreen(),
      ),
      GoRoute(
        path: '/itinerary/:tripId',
        builder: (context, state) =>
            ItineraryScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/route/:tripId',
        builder: (context, state) =>
            RouteOptimizationScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/map/:tripId',
        builder: (context, state) =>
            MapScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/place/:placeId',
        builder: (context, state) =>
            PlaceDetailsScreen(placeId: state.pathParameters['placeId']!),
      ),
    ],
  );
});
