import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/utils/storage.dart';

class ProviderService {
  static final ProviderService _instance = ProviderService._internal();
  factory ProviderService() => _instance;
  ProviderService._internal();

  final _uuid = const Uuid();

  List<ProviderModel> getAllProviders() {
    try {
      final providers = <ProviderModel>[];
      for (var key in GStorage.providers.keys) {
        final data = GStorage.providers.get(key);
        if (data != null) {
          providers.add(ProviderModel.fromMap(Map<String, dynamic>.from(data)));
        }
      }
      return providers;
    } catch (e) {
      debugPrint('getAllProviders error: $e');
      return [];
    }
  }

  ProviderModel? getProvider(String id) {
    try {
      final data = GStorage.providers.get(id);
      if (data != null) {
        return ProviderModel.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addProvider(ProviderModel provider) async {
    try {
      await GStorage.providers.put(provider.id, provider.toMap());
    } catch (e) {
      debugPrint('addProvider error: $e');
    }
  }

  Future<void> updateProvider(ProviderModel provider) async {
    try {
      await GStorage.providers.put(provider.id, provider.toMap());
    } catch (e) {
      debugPrint('updateProvider error: $e');
    }
  }

  Future<void> deleteProvider(String id) async {
    try {
      await GStorage.providers.delete(id);
    } catch (e) {
      debugPrint('deleteProvider error: $e');
    }
  }

  ProviderModel createProvider({
    required String name,
    required String apiFormat,
    required String endpoint,
    required String apiKey,
    bool isPreset = false,
    String apiPath = '/chat/completions',
  }) {
    return ProviderModel(
      id: _uuid.v4(),
      name: name,
      apiFormat: apiFormat,
      endpoint: endpoint,
      apiKey: apiKey,
      isPreset: isPreset,
      apiPath: apiPath,
    );
  }

  Future<void> initPresetProviders() async {
    try {
      if (GStorage.providers.isEmpty) {
        // 预设 DeepSeek
        final deepseek = createProvider(
          name: 'DeepSeek',
          apiFormat: 'openai',
          endpoint: 'https://api.deepseek.com/v1',
          apiKey: '',
          isPreset: true,
          apiPath: '/chat/completions',
        );
        await addProvider(deepseek);

        // 预设 MiMo
        final mimo = createProvider(
          name: 'MiMo',
          apiFormat: 'openai',
          endpoint: 'https://api.xiaomimimo.com/v1',
          apiKey: '',
          isPreset: true,
          apiPath: '/chat/completions',
        );
        await addProvider(mimo);
      }
    } catch (e) {
      debugPrint('initPresetProviders error: $e');
    }
  }
}
