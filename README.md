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
- **Local Storage**: SharedPreferences for persistent data

## Getting Started

### Prerequisites

- Flutter SDK (2.19.0 or higher)
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)
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

3. Create a `.env` file in the root directory with the following content:
   ```
   CLAUDE_API_KEY=your_claude_api_key
   CLAUDE_MODEL=claude-3-opus-20240229
   ```

4. Install dependencies:
   ```
   flutter pub get
   ```

5. Run the app:
   ```
   flutter run
   ```

## Architecture

The application follows a clean architecture approach:

- **Data Layer**: API services, models, repositories
- **Domain Layer**: Entities, use cases
- **Presentation Layer**: BLoCs, screens, widgets

## Contributors

- Jonathan Muhire

## License

This project is licensed under the MIT License - see the LICENSE file for details.
