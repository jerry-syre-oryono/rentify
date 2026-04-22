import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/appwrite_config.dart';
import 'config/router.dart';
import 'providers/appwrite_providers.dart';
import 'utils/theme_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Appwrite config
  AppwriteConfig.init();
  
  runApp(const ProviderScope(child: RentifyApp()));
}

class RentifyApp extends ConsumerWidget {
  const RentifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: 'Rentify - Premium Rentals',
      themeMode: ThemeMode.system, // Adapt to system theme
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RentifyTheme.goldPrimary,
        brightness: Brightness.light,
        primary: RentifyTheme.goldPrimary,
        secondary: RentifyTheme.deepSlate,
        tertiary: RentifyTheme.skyBlue,
        surface: RentifyTheme.lightBg,
      ),
      scaffoldBackgroundColor: RentifyTheme.lightBg,
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: RentifyTheme.lightBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: RentifyTheme.deepSlate,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: RentifyTheme.deepSlate),
      ),

      // Cards with Glass Morphism
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: RentifyTheme.goldPrimary.withOpacity(0.15),
            width: 1.5,
          ),
        ),
      ),

      // Elevated Button with Gradient
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          backgroundColor: RentifyTheme.goldPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shadowColor: RentifyTheme.goldPrimary.withOpacity(0.4),
        ),
      ),

      // Text Input Fields with Animated Labels
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RentifyTheme.lightBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        floatingLabelStyle: const TextStyle(
          color: RentifyTheme.goldPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RentifyTheme.goldPrimary,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RentifyTheme.goldPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RentifyTheme.goldPrimary,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE63946), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE63946), width: 2.5),
        ),
        prefixIconColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.focused)
                ? RentifyTheme.goldPrimary
                : RentifyTheme.deepSlate),
        suffixIconColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.focused)
                ? RentifyTheme.goldPrimary
                : RentifyTheme.deepSlate),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 12,
        selectedItemColor: RentifyTheme.goldPrimary,
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),

      // Text Theme with better hierarchy
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: RentifyTheme.deepSlate,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: RentifyTheme.deepSlate,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: RentifyTheme.deepSlate,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color: RentifyTheme.deepSlate,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: RentifyTheme.deepSlate,
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RentifyTheme.goldPrimary,
        brightness: Brightness.dark,
        primary: RentifyTheme.goldPrimary,
        secondary: RentifyTheme.deepSlate,
        tertiary: RentifyTheme.skyBlue,
        surface: RentifyTheme.darkBg,
      ),
      scaffoldBackgroundColor: RentifyTheme.darkBg,

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: RentifyTheme.darkBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Cards with Glass Morphism
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF2A2A2A),
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: RentifyTheme.goldPrimary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          backgroundColor: RentifyTheme.goldPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shadowColor: RentifyTheme.goldPrimary.withOpacity(0.5),
        ),
      ),

      // Text Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        floatingLabelStyle: const TextStyle(
          color: RentifyTheme.goldPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RentifyTheme.goldPrimary,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RentifyTheme.goldPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RentifyTheme.goldPrimary,
            width: 2.5,
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1B1B1B),
        elevation: 16,
        selectedItemColor: RentifyTheme.goldPrimary,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.5,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}
