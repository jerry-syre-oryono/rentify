import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite;
import 'appwrite_providers.dart';

// Authentication State
class AuthState {
  final bool isLoading;
  final appwrite.User? user;
  final String? error;
  
  AuthState({this.isLoading = false, this.user, this.error});
  
  AuthState copyWith({bool? isLoading, appwrite.User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // We can't use async here, so we do it in an init method or just return initial state.
    // However, we can call a function to load the user.
    Future.microtask(() => init());
    return AuthState(isLoading: true);
  }

  Future<void> init() async {
    try {
      final account = ref.read(accountProvider);
      final user = await account.get();
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false);
    }
  }
  
  Future<bool> register(String email, String password, String name) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final account = ref.read(accountProvider);
      
      // Create user account
      await account.create(
        userId: ID.unique(), // Auto-generate ID
        email: email,
        password: password,
        name: name,
      );
      
      // Auto-login after registration
      await account.createEmailPasswordSession(email: email, password: password);
      
      // Fetch and update user
      final user = await account.get();
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final account = ref.read(accountProvider);
      
      try {
        await account.createEmailPasswordSession(
          email: email,
          password: password,
        );
      } catch (e) {
        // If session already exists, we can ignore this error and just get the user
        if (e.toString().contains('user_session_already_exists')) {
          print('Session already active, fetching user...');
        } else {
          rethrow;
        }
      }
      
      final user = await account.get();
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      final account = ref.read(accountProvider);
      await account.deleteSession(sessionId: 'current');
      state = AuthState(); // Reset state
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<bool> updateUser({String? name, String? email}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final account = ref.read(accountProvider);

      if (name != null) {
        await account.updateName(name: name);
      }

      if (email != null) {
        // Appwrite requires the current password to update the email
        // This is a placeholder for the actual implementation
        // You would need to prompt the user for their password
        // await account.updateEmail(email: email, password: 'current-password');
      }

      final user = await account.get();
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => state.user != null;
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
