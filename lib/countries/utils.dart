import 'translations.dart';

String getTranslation(String word, Map<String, String> translations) {
  return translations[word] ?? word;
}