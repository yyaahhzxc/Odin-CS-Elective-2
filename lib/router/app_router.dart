import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/fruit_detail_screen.dart';
import '../screens/fruit_list_screen.dart';
import '../screens/not_found_screen.dart';

/// Central router configuring nested routes using go_router.
/// - Root route: '/' -> [FruitListScreen] (List of fruits)
/// - Nested sub-route: 'fruit/:name' -> [FruitDetailScreen] (Fruit illustration & description)
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'fruits_list',
        builder: (BuildContext context, GoRouterState state) {
          return const FruitListScreen();
        },
        routes: <RouteBase>[
          // Nested route under '/' -> resolves to '/fruit/:name'
          GoRoute(
            path: 'fruit/:name',
            name: 'fruit_detail',
            builder: (BuildContext context, GoRouterState state) {
              final fruitName = state.pathParameters['name'] ?? '';
              return FruitDetailScreen(fruitName: fruitName);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return NotFoundScreen(errorMessage: state.error?.message);
    },
  );
}
