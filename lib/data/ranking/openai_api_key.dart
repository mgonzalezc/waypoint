/// OpenAI API key, direct client call.
///
/// Never hardcode a real key here. Set it at build/run time instead:
///   flutter run --dart-define=OPENAI_API_KEY=sk-...
/// (or add "--dart-define-from-file=dart_define.local.json" to the args in
/// .vscode/launch.json, pointing at a local, gitignored file).
const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
