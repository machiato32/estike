Map<String, String> englishEquivalents = {
  'á': 'a',
  'é': 'e',
  'ó': 'o',
  'ö': 'o',
  'ő': 'o',
  'ú': 'u',
  'ü': 'u',
  'ű': 'u',
  'í': 'i',
};

extension EnglishAlphabet on String {
  String toEnglishAlphabet() {
    String newString = this;
    for (String char in englishEquivalents.keys) {
      newString = newString.replaceAll(char, englishEquivalents[char]!);
    }
    return newString;
  }
}
