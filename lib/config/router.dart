import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/property/property_details_screen.dart';
import '../screens/property/booking_screen.dart';
import '../screens/booking/booking_history_screen.dart';
import '../screens/home/favorites_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/seller/add_property_screen.dart';
import '../screens/seller/edit_property_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/scan_booking_screen.dart';
import '../screens/seller/property_bookings_screen.dart';
import '../screens/booking/booking_details_screen.dart';
import '../models/property_model.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';
import '../utils/theme_constants.dart';

import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

// Shell Scaffold with Bottom Navigation
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == AppConstants.routeHome) return 0;
    if (location == AppConstants.routeFavorites) return 1;
    if (location == AppConstants.routeMyBookings) return 2;
    if (location == AppConstants.routeProfile) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppConstants.routeHome);
        break;
      case 1:
        context.go(AppConstants.routeFavorites);
        break;
      case 2:
        context.go(AppConstants.routeMyBookings);
        break;
      case 3:
        context.go(AppConstants.routeProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1B1B1B) : Colors.white,
          selectedItemColor: RentifyTheme.goldPrimary,
          unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[500],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online_outlined),
              activeIcon: Icon(Icons.book_online_rounded),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isGoingToAuth = state.uri.path == AppConstants.routeLogin || 
                           state.uri.path == AppConstants.routeRegister;
      
      if (!isLoggedIn && !isGoingToAuth && state.uri.path != AppConstants.routeSplash) {
        return AppConstants.routeLogin;
      }
      if (isLoggedIn && isGoingToAuth) {
        return AppConstants.routeHome;
      }
      return null;
    },
    routes: [
      // Splash redirect
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        redirect: (context, state) => authState.user != null 
            ? AppConstants.routeHome 
            : AppConstants.routeLogin,
      ),
      
      // Auth routes
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Shell Route for Main App
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.routeFavorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppConstants.routeMyBookings,
            builder: (context, state) => const BookingHistoryScreen(),
          ),
          GoRoute(
            path: AppConstants.routeProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Routes outside Shell (no bottom nav)
      GoRoute(
        path: '${AppConstants.routePropertyDetails}/:id',
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) {
            return const Scaffold(
              body: Center(child: Text('Property not found')),
            );
          }
          return PropertyDetailsScreen(property: property);
        },
      ),
      GoRoute(
        path: AppConstants.routeBooking,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final property = args?['property'] as Property?;
          if (property == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid booking request')),
            );
          }
          return BookingScreen(property: property);
        },
      ),
      GoRoute(
        path: AppConstants.routeAddProperty,
        builder: (context, state) => const AddPropertyScreen(),
      ),
      GoRoute(
        path: AppConstants.routeEditProperty,
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) {
            return const Scaffold(body: Center(child: Text('Property data missing')));
          }
          return EditPropertyScreen(property: property);
        },
      ),
      GoRoute(
        path: AppConstants.routeSellerDashboard,
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeBookingDetails,
        builder: (context, state) {
          final booking = state.extra as Booking?;
          if (booking == null) return const Scaffold(body: Center(child: Text('Booking data missing')));
          return BookingDetailsScreen(booking: booking);
        },
      ),
      GoRoute(
        path: AppConstants.routeScanBooking,
        builder: (context, state) => const ScanBookingScreen(),
      ),
      GoRoute(
        path: AppConstants.routePropertyBookings,
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) return const Scaffold(body: Center(child: Text('Property data missing')));
          return PropertyBookingsScreen(property: property);
        },
      ),
    ],
  );
});