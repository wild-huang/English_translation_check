import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:trans_flutter/models/theme_color_type.dart';
import 'package:trans_flutter/router/app_pages.dart';
import 'package:trans_flutter/services/provider_service.dart';
import 'package:trans_flutter/utils/storage.dart';
import 'package:trans_flutter/utils/storage_pref.dart';
import 'package:trans_flutter/utils/theme_utils.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await GStorage.init();
      await ProviderService().initPresetProviders();
    } catch (e) {
      debugPrint('Storage init error: $e');
    }
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
    
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Error: $error');
    debugPrint('Stack: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '翻译检查',
      theme: _getTheme(Brightness.light),
      darkTheme: _getTheme(Brightness.dark),
      themeMode: _getThemeMode(),
      initialRoute: '/',
      getPages: Routes.getPages,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 150),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  ThemeData _getTheme(Brightness brightness) {
    try {
      final colorIndex = Pref.customColor.clamp(0, colorThemeTypes.length - 1);
      return ThemeUtils.getThemeData(
        colorScheme: SeedColorScheme.fromSeeds(
          primaryKey: colorThemeTypes[colorIndex].color,
          brightness: brightness,
        ),
        isDynamic: false,
        isDark: brightness == Brightness.dark,
      );
    } catch (e) {
      return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: brightness,
      );
    }
  }

  ThemeMode _getThemeMode() {
    try {
      return Pref.themeMode;
    } catch (e) {
      return ThemeMode.system;
    }
  }
}
