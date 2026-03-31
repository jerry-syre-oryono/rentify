import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/property/property_details_screen.dart';
import '../screens/property/booking_screen.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';

// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isGoingToAuth = state.uri.path == AppConstants.routeLogin || 
                           state.uri.path == AppConstants.routeRegister;
      
      if (!isLoggedIn && !isGoingToAuth) {
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
      
      // Main app routes
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const HomeScreen(),
      ),
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
    ],
  );
});