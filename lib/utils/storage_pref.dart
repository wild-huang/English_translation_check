import 'package:flutter/material.dart';
import 'package:trans_flutter/utils/storage.dart';
import 'package:trans_flutter/utils/storage_key.dart';

abstract final class Pref {
  static ThemeMode get themeMode {
    try {
      final value = GStorage.setting.get(SettingBoxKey.themeMode, defaultValue: 'system');
      switch (value) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  static set themeMode(ThemeMode mode) {
    try {
      GStorage.setting.put(SettingBoxKey.themeMode, mode.name);
    } catch (e) {}
  }

  static bool get dynamicColor {
    try {
      return GStorage.setting.get(SettingBoxKey.dynamicColor, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  static set dynamicColor(bool value) {
    try {
      GStorage.setting.put(SettingBoxKey.dynamicColor, value);
    } catch (e) {}
  }

  static int get customColor {
    try {
      return GStorage.setting.get(SettingBoxKey.customColor, defaultValue: 0);
    } catch (e) {
      return 0;
    }
  }

  static set customColor(int value) {
    try {
      GStorage.setting.put(SettingBoxKey.customColor, value);
    } catch (e) {}
  }

  static bool get isPureBlackTheme {
    try {
      return GStorage.setting.get(SettingBoxKey.isPureBlackTheme, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  static set isPureBlackTheme(bool value) {
    try {
      GStorage.setting.put(SettingBoxKey.isPureBlackTheme, value);
    } catch (e) {}
  }

  static String? get selectedProviderId {
    try {
      return GStorage.setting.get(SettingBoxKey.selectedProviderId);
    } catch (e) {
      return null;
    }
  }

  static set selectedProviderId(String? value) {
    try {
      if (value == null) {
        GStorage.setting.delete(SettingBoxKey.selectedProviderId);
      } else {
        GStorage.setting.put(SettingBoxKey.selectedProviderId, value);
      }
    } catch (e) {}
  }

  static String? get selectedModelId {
    try {
      return GStorage.setting.get(SettingBoxKey.selectedModelId);
    } catch (e) {
      return null;
    }
  }

  static set selectedModelId(String? value) {
    try {
      if (value == null) {
        GStorage.setting.delete(SettingBoxKey.selectedModelId);
      } else {
        GStorage.setting.put(SettingBoxKey.selectedModelId, value);
      }
    } catch (e) {}
  }

  static bool get aiFreeComment {
    try {
      return GStorage.setting.get(SettingBoxKey.aiFreeComment, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  static set aiFreeComment(bool value) {
    try {
      GStorage.setting.put(SettingBoxKey.aiFreeComment, value);
    } catch (e) {}
  }
}
