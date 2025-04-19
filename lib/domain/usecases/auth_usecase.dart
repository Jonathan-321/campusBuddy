import 'dart:async';
import '../entities/user.dart';

// Mock for development to avoid Firebase dependency issues
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

class AuthUseCase {
  // Mock user for development
  MockUser? _currentUser;
  final StreamController<MockUser?> _authStateController =
      StreamController<MockUser?>.broadcast();

  AuthUseCase() {
    // Initialize the stream with null (not authenticated)
    _authStateController.add(null);
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      if (_currentUser == null) {
        return const User.empty();
      }
      return User(
        id: _currentUser!.uid,
        email: _currentUser!.email ?? '',
        name: _currentUser!.displayName,
        photoUrl: _currentUser!.photoURL,
        isAuthenticated: true,
      );
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  // Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      print('Mock signing in user with email: $email');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // For development, accept any credentials
      if (password.length < 6) {
        throw Exception('Wrong password');
      }

      // Create mock user
      _currentUser = MockUser(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: name ?? 'Test User',
        photoURL: null,
      );

      // Notify auth state change
      _authStateController.add(_currentUser);

      print('Mock user signed in successfully');

      return User(
        id: _currentUser!.uid,
        email: email,
        name: _currentUser!.displayName,
        photoUrl: _currentUser!.photoURL,
        isAuthenticated: true,
      );
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  // Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Mock signing up user with email: $email');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate password
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create mock user
      _currentUser = MockUser(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: name,
        photoURL: null,
      );

      // Notify auth state change
      _authStateController.add(_currentUser);

      print('Mock user signed up successfully');

      return User(
        id: _currentUser!.uid,
        email: email,
        name: _currentUser!.displayName,
        photoUrl: _currentUser!.photoURL,
        isAuthenticated: true,
      );
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Get auth state changes stream
  Stream<User> get authStateChanges => _authStateController.stream.map(
        (mockUser) => mockUser == null
            ? const User.empty()
            : User(
                id: mockUser.uid,
                email: mockUser.email ?? '',
                name: mockUser.displayName,
                photoUrl: mockUser.photoURL,
                isAuthenticated: mockUser != null,
              ),
      );

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      print('Mock password reset email sent to: $email');
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
