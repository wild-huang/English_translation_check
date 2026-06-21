class CheckResult {
  final String category;
  final String title;
  final String content;
  final List<CheckItem> items;

  CheckResult({
    required this.category,
    required this.title,
    required this.content,
    required this.items,
  });
}

class CheckItem {
  final String issue;
  final String explanation;
  final String suggestion;

  CheckItem({
    required this.issue,
    required this.explanation,
    required this.suggestion,
  });
}

class TranslationCheckResponse {
  final List<CheckResult> results;
  final String? aiComment;
  final String? suggestedTranslation;

  TranslationCheckResponse({
    required this.results,
    this.aiComment,
    this.suggestedTranslation,
  });
}
