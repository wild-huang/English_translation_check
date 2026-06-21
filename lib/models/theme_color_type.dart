import 'package:flutter/material.dart';

class ThemeColorType {
  final String name;
  final Color color;

  const ThemeColorType({required this.name, required this.color});
}

final List<ThemeColorType> colorThemeTypes = [
  const ThemeColorType(name: '蓝色', color: Colors.blue),
  const ThemeColorType(name: '酒红色', color: Color(0xFF8B0000)),
  const ThemeColorType(name: '青色', color: Colors.cyan),
  const ThemeColorType(name: '紫色', color: Colors.purple),
  const ThemeColorType(name: '绿色', color: Colors.green),
];
