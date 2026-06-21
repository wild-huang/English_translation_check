import 'package:uuid/uuid.dart';
import 'package:trans_flutter/models/ai_model.dart';
import 'package:trans_flutter/utils/storage.dart';

class ModelService {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  final _uuid = const Uuid();

  List<AIModel> getAllModels() {
    final models = <AIModel>[];
    for (var key in GStorage.models.keys) {
      final data = GStorage.models.get(key);
      if (data != null) {
        models.add(AIModel.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    return models;
  }

  List<AIModel> getModelsByProvider(String providerId) {
    return getAllModels().where((m) => m.providerId == providerId).toList();
  }

  AIModel? getModel(String id) {
    final data = GStorage.models.get(id);
    if (data != null) {
      return AIModel.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> addModel(AIModel model) async {
    await GStorage.models.put(model.id, model.toMap());
  }

  Future<void> addModels(List<AIModel> models) async {
    for (var model in models) {
      await GStorage.models.put(model.id, model.toMap());
    }
  }

  Future<void> deleteModelsByProvider(String providerId) async {
    final models = getModelsByProvider(providerId);
    for (var model in models) {
      await GStorage.models.delete(model.id);
    }
  }

  Future<void> clearModels() async {
    await GStorage.models.clear();
  }

  AIModel createModel({
    required String providerId,
    required String name,
    required String displayName,
  }) {
    return AIModel(
      id: _uuid.v4(),
      providerId: providerId,
      name: name,
      displayName: displayName,
    );
  }
}
