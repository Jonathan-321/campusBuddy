# Campus Buddy

A comprehensive mobile application for university students at Oklahoma Christian University.

## Features

- **Authentication**: Email and password-based authentication with user profiles
- **Campus Oracle**: AI-powered chatbot to answer questions about campus life
  - Conversation storage and history
  - Multi-language support
- **Profile Management**: User profile viewing and management
- **Home Screen**: Dashboard with campus information

## Technologies

- **Frontend**: Flutter for cross-platform mobile development
- **State Management**: Flutter BLoC pattern
- **Navigation**: Go Router for declarative routing
- **AI Integration**: Claude API for natural language processing
- **Backend**: Firebase Authentication, Firestore
- **Local Storage**: SharedPreferences for persistent data

## Getting Started

### Prerequisites

- Flutter SDK (2.19.0 or higher)
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)
- Firebase project with Auth, Firestore enabled
- Anthropic API key for Claude AI

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/Jonathan-321/campusBuddy.git
   ```

2. Navigate to the project directory:
   ```
   cd campusBuddy
   ```

3. Create a `.env` file in the root directory based on the `.env.example` template:
   ```
   cp .env.example .env
   ```
   
4. Add your API keys and Firebase configuration to the `.env` file:
   ```
   # AI Configuration
   CLAUDE_API_KEY=your_claude_api_key
   CLAUDE_MODEL=claude-3-opus-20240229
   
   # Firebase Configuration
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
   FIREBASE_AUTH_DOMAIN=your_auth_domain
   
   # Firebase App IDs
   FIREBASE_WEB_APP_ID=your_web_app_id
   FIREBASE_ANDROID_APP_ID=your_android_app_id
   FIREBASE_IOS_APP_ID=your_ios_app_id
   FIREBASE_MACOS_APP_ID=your_macos_app_id
   
   # iOS/macOS specific configurations
   FIREBASE_IOS_CLIENT_ID=your_ios_client_id
   FIREBASE_IOS_BUNDLE_ID=your_ios_bundle_id
   ```

5. Install dependencies:
   ```
   flutter pub get
   ```

6. Run the app:
   ```
   flutter run
   ```

## Security Notes

- **Environment Variables**: Never commit your `.env` file with actual API keys to version control
- **API Keys**: If you accidentally expose API keys, rotate them immediately in your service provider's console
- **Firebase**: The app uses environment variables for Firebase configuration to avoid hardcoding sensitive values

## Architecture

The application follows a clean architecture approach:

- **Data Layer**: API services, models, repositories
- **Domain Layer**: Entities, use cases
- **Presentation Layer**: BLoCs, screens, widgets

## Contributors

- Jonathan Muhire

## License

This project is licensed under the MIT License - see the LICENSE file for details.
