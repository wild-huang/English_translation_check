import 'package:flutter/material.dart';
import 'package:trans_flutter/models/theme_color_type.dart';
import 'package:trans_flutter/utils/storage_pref.dart';
import 'package:trans_flutter/utils/theme_utils.dart';

class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({super.key});

  @override
  State<ThemeSettingPage> createState() => _ThemeSettingPageState();
}

class _ThemeSettingPageState extends State<ThemeSettingPage> {
  ThemeMode _themeMode = Pref.themeMode;
  bool _isPureBlackTheme = Pref.isPureBlackTheme;
  int _customColor = Pref.customColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
      ),
      body: ListView(
        children: [
          // 外观模式
          _buildSectionTitle(theme, '外观模式'),
          _buildThemeModeSelector(theme),
          
          const Divider(height: 32),
          
          // OLED优化模式
          _buildSectionTitle(theme, 'OLED优化'),
          SwitchListTile(
            title: const Text('纯黑背景'),
            subtitle: const Text('适用于OLED屏幕，可省电'),
            value: _isPureBlackTheme,
            onChanged: (value) {
              setState(() {
                _isPureBlackTheme = value;
                Pref.isPureBlackTheme = value;
              });
              _updateTheme();
            },
          ),
          
          const Divider(height: 32),
          
          // 预设主题色
          _buildSectionTitle(theme, '预设主题色'),
          _buildColorSelector(theme),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(ThemeData theme) {
    return Column(
      children: [
        _buildThemeModeTile(
          theme,
          icon: Icons.brightness_auto_outlined,
          title: '跟随系统',
          mode: ThemeMode.system,
        ),
        _buildThemeModeTile(
          theme,
          icon: Icons.light_mode_outlined,
          title: '浅色模式',
          mode: ThemeMode.light,
        ),
        _buildThemeModeTile(
          theme,
          icon: Icons.dark_mode_outlined,
          title: '深色模式',
          mode: ThemeMode.dark,
        ),
      ],
    );
  }

  Widget _buildThemeModeTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required ThemeMode mode,
  }) {
    final isSelected = _themeMode == mode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: () {
        setState(() {
          _themeMode = mode;
          Pref.themeMode = mode;
        });
        _updateTheme();
      },
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          colorThemeTypes.length,
          (index) {
            final colorType = colorThemeTypes[index];
            final isSelected = _customColor == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _customColor = index;
                  Pref.customColor = index;
                });
                _updateTheme();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorType.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: colorType.color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 28,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateTheme() {
    final (light, dark) = ThemeUtils.getAllTheme();
    ThemeUtils.lightTheme = light;
    ThemeUtils.darkTheme = dark;
    ThemeUtils.themeMode = _themeMode;
  }
}
