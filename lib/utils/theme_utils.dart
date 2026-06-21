import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:trans_flutter/models/theme_color_type.dart';
import 'package:trans_flutter/utils/storage_pref.dart';

abstract final class ThemeUtils {
  static late ThemeData lightTheme;
  static late ThemeData darkTheme;
  static late ThemeMode themeMode;

  static ThemeData get theme {
    if (themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            PlatformDispatcher.instance.platformBrightness == Brightness.dark)) {
      return darkTheme;
    }
    return lightTheme;
  }

  static bool get isDarkMode => theme.brightness == Brightness.dark;

  static (ThemeData, ThemeData) getAllTheme() {
    final dynamicColor = Pref.dynamicColor;
    late final brandColor = colorThemeTypes[Pref.customColor].color;
    
    return (
      lightTheme = getThemeData(
        colorScheme: SeedColorScheme.fromSeeds(
          primaryKey: brandColor,
          brightness: Brightness.light,
        ),
        isDynamic: dynamicColor,
      ),
      darkTheme = getThemeData(
        isDark: true,
        colorScheme: SeedColorScheme.fromSeeds(
          primaryKey: brandColor,
          brightness: Brightness.dark,
        ),
        isDynamic: dynamicColor,
      ),
    );
  }

  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
  }) {
    ThemeData themeData = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: isDynamic ? colorScheme.onSurfaceVariant : null,
        shadowColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surface,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: const SwitchThemeData(
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
    
    if (isDark) {
      if (Pref.isPureBlackTheme) {
        themeData = darkenTheme(themeData);
      }
    }
    return themeData;
  }

  static ThemeData darkenTheme(ThemeData themeData) {
    final colorScheme = themeData.colorScheme;
    return themeData.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: themeData.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: themeData.cardTheme.copyWith(
        color: Colors.black,
      ),
      dialogTheme: themeData.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      colorScheme: colorScheme.copyWith(
        surface: Colors.black,
        onSurface: colorScheme.onSurface,
        surfaceContainerHighest: const Color(0xFF1C1C1C),
      ),
    );
  }
}
