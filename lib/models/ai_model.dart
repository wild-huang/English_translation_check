import 'package:hive_ce/hive.dart';

part 'ai_model.g.dart';

@HiveType(typeId: 1)
class AIModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String providerId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String displayName;

  AIModel({
    required this.id,
    required this.providerId,
    required this.name,
    required this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'displayName': displayName,
    };
  }

  factory AIModel.fromMap(Map<String, dynamic> map) {
    return AIModel(
      id: map['id'] as String,
      providerId: map['providerId'] as String,
      name: map['name'] as String,
      displayName: map['displayName'] as String,
    );
  }
}
