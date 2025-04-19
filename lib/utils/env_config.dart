import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration utility
///
/// Provides access to environment variables used in the application
/// Loads the .env file and provides access to its values
class EnvConfig {
  /// Get the API key for Claude AI model
  static String get claudeApiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  /// Get the model name for Claude AI
  static String get claudeModel =>
      dotenv.env['CLAUDE_MODEL'] ?? 'claude-3-opus-20240229';

  /// Checks if all required environment variables are set
  static bool validateAiConfig() {
    final hasClaudeApiKey = claudeApiKey.isNotEmpty;
    final hasClaudeModel = claudeModel.isNotEmpty;

    return hasClaudeApiKey && hasClaudeModel;
  }
}
