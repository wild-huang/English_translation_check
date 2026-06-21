import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

String appSupportDirPath = '';

abstract final class GStorage {
  static Box<dynamic>? _setting;
  static Box<dynamic>? _providers;
  static Box<dynamic>? _models;

  static Box<dynamic> get setting => _setting!;
  static Box<dynamic> get providers => _providers!;
  static Box<dynamic> get models => _models!;

  static Future<void> init() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      appSupportDirPath = appDir.path;
      Hive.init(path.join(appSupportDirPath, 'hive'));

      _setting = await Hive.openBox('setting');
      _providers = await Hive.openBox('providers');
      _models = await Hive.openBox('models');
    } catch (e) {
      debugPrint('GStorage init error: $e');
      rethrow;
    }
  }

  static String exportAllSettings() {
    return jsonEncode({
      'setting': _setting?.toMap() ?? {},
      'providers': _providers?.toMap() ?? {},
      'models': _models?.toMap() ?? {},
    });
  }

  static Future<void> importAllSettings(String data) async {
    final map = jsonDecode(data);
    await Future.wait([
      _setting?.clear().then((_) => _setting?.putAll(map['setting'] ?? {})) ?? Future.value(),
      _providers?.clear().then((_) => _providers?.putAll(map['providers'] ?? {})) ?? Future.value(),
      _models?.clear().then((_) => _models?.putAll(map['models'] ?? {})) ?? Future.value(),
    ]);
  }

  static Future<List<void>> clear() {
    return Future.wait([
      _setting?.clear() ?? Future.value(),
      _providers?.clear() ?? Future.value(),
      _models?.clear() ?? Future.value(),
    ]);
  }
}
