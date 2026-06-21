import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // 导入（供应商管理）
          _buildSettingItem(
            context,
            icon: Icons.cloud_upload_outlined,
            title: '导入',
            subtitle: '管理AI供应商配置',
            onTap: () => Get.toNamed('/providerManage'),
          ),
          
          // 模型选择
          _buildSettingItem(
            context,
            icon: Icons.smart_toy_outlined,
            title: '模型选择',
            subtitle: '选择AI模型',
            onTap: () => Get.toNamed('/modelSelect'),
          ),
          
          // 主题
          _buildSettingItem(
            context,
            icon: Icons.palette_outlined,
            title: '主题',
            subtitle: '外观模式、主题色',
            onTap: () => Get.toNamed('/themeSetting'),
          ),
          
          const Divider(height: 32),
          
          // 关于
          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '翻译检查',
                applicationVersion: '1.0.0',
                applicationLegalese: '上海高考英语中译英检查工具',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
