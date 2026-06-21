import 'package:hive_ce/hive.dart';

part 'provider_model.g.dart';

@HiveType(typeId: 0)
class ProviderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String apiFormat; // 'openai' or 'anthropic'

  @HiveField(3)
  String endpoint; // base url, e.g. https://api.deepseek.com

  @HiveField(4)
  String apiKey;

  @HiveField(5)
  bool isPreset;

  @HiveField(6)
  String apiPath; // e.g. /chat/completions

  ProviderModel({
    required this.id,
    required this.name,
    required this.apiFormat,
    required this.endpoint,
    required this.apiKey,
    this.isPreset = false,
    this.apiPath = '/chat/completions',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apiFormat': apiFormat,
      'endpoint': endpoint,
      'apiKey': apiKey,
      'isPreset': isPreset,
      'apiPath': apiPath,
    };
  }

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      apiFormat: map['apiFormat'] as String,
      endpoint: map['endpoint'] as String,
      apiKey: map['apiKey'] as String,
      isPreset: map['isPreset'] as bool? ?? false,
      apiPath: map['apiPath'] as String? ?? '/chat/completions',
    );
  }
}
