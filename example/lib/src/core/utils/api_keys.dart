class ApiKeys {
  /// API Key for authentication with the Eleven Labs API.
  static const String elevenLabApiKey =
      String.fromEnvironment('elevenLabApiKey');
  static const String deepgramApiKey = String.fromEnvironment('deepgramApiKey');

  ///API key for the authentication with the Simli Avatar API
  static const String simliApiKey = String.fromEnvironment('simliApiKey');

  ///Api keys for the groq
  static const String groqApiKey = String.fromEnvironment('groqApiKey');
}
