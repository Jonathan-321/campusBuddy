/// Campus Buddy - Main Application Entry Point
///
/// This file serves as the entry point for the Campus Buddy application.
/// It initializes the app with necessary configurations, services, and state management.
///
/// Key Responsibilities:
/// 1. Initialize Flutter bindings and services
/// 2. Set up theme configurations
/// 3. Configure state management (BLoC providers)
/// 4. Initialize navigation (GoRouter)
/// 5. Set up app-wide configurations
///
/// Dependencies:
/// - flutter_bloc: For state management
/// - go_router: For navigation
/// - flutter_local_notifications: For notifications
///
/// Architecture:
/// The app follows Clean Architecture with the following layers:
/// - Presentation (UI)
/// - Domain (Business Logic)
/// - Data (Data Sources)
/// - Services (External Services)
///
/// State Management:
/// The app uses BLoC pattern with the following BLoCs:
/// - AuthBloc: Handles authentication state
/// - CoursesBloc: Manages course-related state
/// - EventsBloc: Manages event-related state
/// - CampusAIBloc: Manages campus AI-related state
///
/// Navigation:
/// Uses GoRouter for declarative routing with:
/// - Root navigation for auth flows
/// - Shell navigation for main app sections
/// - Nested navigation for feature-specific screens
///
/// Theme:
/// Supports both light and dark themes with:
/// - Material 3 design system
/// - Custom color schemes
/// - Consistent component styling
///
/// Usage:
/// To add new features:
/// 1. Create necessary BLoC
/// 2. Add routes in AppRouter
/// 3. Create corresponding screens
/// 4. Update theme if needed
///
/// Note: This file should remain focused on app initialization and configuration.
/// Business logic should be implemented in respective feature modules.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'utils/firebase_config.dart';
import 'utils/env_config.dart';
import 'data/services/ai_service.dart';
import 'domain/usecases/auth_usecase.dart';

/// Application entry point
///
/// Initializes:
/// 1. Flutter bindings
/// 2. Notification service
/// 3. Screen orientation
/// 4. Required use cases
/// 5. Main app widget
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file for API keys and configuration
  await dotenv.load(fileName: '.env');
  debugPrint('Environment variables loaded successfully');

  // Validate AI configuration
  if (EnvConfig.validateAiConfig()) {
    debugPrint('AI configuration validated successfully');
  } else {
    debugPrint(
        'Warning: AI configuration is incomplete. Some features may not work.');
  }

  // Validate Firebase configuration
  if (SecureFirebaseOptions.validateFirebaseConfig()) {
    debugPrint('Firebase configuration validated successfully');
  } else {
    debugPrint(
        'Warning: Firebase configuration is incomplete. Some features may not work.');
  }

  // Initialize Firebase safely (only if not already initialized)
  try {
    // Check if Firebase is already initialized to avoid duplicate initialization
    if (!Firebase.apps.isNotEmpty) {
      await Firebase.initializeApp(
        options: SecureFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase was already initialized');
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    // Continue without Firebase if there's an error
  }

  // Preload university data for AI assistant
  final aiService = AiService();
  await aiService.loadUniversityData();
  debugPrint('University data loading attempted');

  // Set preferred screen orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create auth use case
  final authUseCase = AuthUseCase();

  // Run the application with required dependencies
  runApp(App(
    authUseCase: authUseCase,
  ));
}
