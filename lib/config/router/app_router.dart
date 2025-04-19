/// Campus Buddy - Navigation Configuration
///
/// This file configures the application's navigation using GoRouter.
/// It defines the essential routes for the app.
///
/// Navigation Structure:
/// 1. Root Routes:
///    - Splash Screen (/)
///    - Authentication Routes (/login, /signup)
///
/// 2. Main App Shell (Bottom Navigation):
///    - Home (/home)
///    - Campus Oracle (/campus-oracle)
///    - Profile (/profile)
///
/// Navigation Keys:
/// - _rootNavigatorKey: For root-level navigation
/// - _shellNavigatorKey: For bottom navigation shell
///
/// Usage:
/// To add new routes:
/// 1. Import the corresponding screen
/// 2. Add route definition in appropriate section
/// 3. Update bottom navigation if needed
///
/// Note: Keep routes organized by feature and maintain consistent
/// naming conventions for path parameters.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import screens
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/campus_oracle_screen.dart';

/// AppRouter handles all navigation in the app using GoRouter
class AppRouter {
  /// Root navigator key for top-level navigation
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Shell navigator key for bottom navigation
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Creates the GoRouter instance with all routes
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen as initial route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main app shell with nested routes
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Campus Oracle tab
          GoRoute(
            path: '/campus-oracle',
            builder: (context, state) => const CampusOracleScreen(),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}

/// Scaffold with bottom navigation bar for the main app shell
///
/// This widget provides the main app layout with:
/// 1. Bottom navigation bar
/// 2. Content area for current route
/// 3. Navigation state management
class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  /// Bottom navigation items configuration
  ///
  /// Defines:
  /// - Icons for each tab
  /// - Labels for each tab
  /// - Initial routes for each tab
  static const List<_BottomNavItem> _bottomNavItems = [
    _BottomNavItem(
      icon: Icons.home,
      label: 'Home',
      initialLocation: '/home',
    ),
    _BottomNavItem(
      icon: Icons.chat,
      label: 'Campus AI',
      initialLocation: '/campus-oracle',
    ),
    _BottomNavItem(
      icon: Icons.person,
      label: 'Profile',
      initialLocation: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _goOtherTab(context, index);
        },
        items: _bottomNavItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  /// Handles navigation between bottom tabs
  ///
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - index: Index of the tab to navigate to
  void _goOtherTab(BuildContext context, int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_bottomNavItems[index].initialLocation);
  }
}

/// Helper class for bottom navigation item configuration
///
/// Contains:
/// - icon: IconData for the tab
/// - label: Text label for the tab
/// - initialLocation: Route path for the tab
class _BottomNavItem {
  final IconData icon;
  final String label;
  final String initialLocation;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.initialLocation,
  });
}
