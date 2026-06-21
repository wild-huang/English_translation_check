abstract final class SettingBoxKey {
  static const String themeMode = 'themeMode';
  static const String dynamicColor = 'dynamicColor';
  static const String customColor = 'customColor';
  static const String isPureBlackTheme = 'isPureBlackTheme';
  static const String selectedProviderId = 'selectedProviderId';
  static const String selectedModelId = 'selectedModelId';
  static const String aiFreeComment = 'aiFreeComment';
}

abstract final class ProviderBoxKey {
  static const String id = 'id';
  static const String name = 'name';
  static const String apiFormat = 'apiFormat';
  static const String endpoint = 'endpoint';
  static const String apiKey = 'apiKey';
  static const String isPreset = 'isPreset';
}

abstract final class ModelBoxKey {
  static const String id = 'id';
  static const String providerId = 'providerId';
  static const String name = 'name';
  static const String displayName = 'displayName';
}
