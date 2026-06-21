import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/services/provider_service.dart';

class ProviderManagePage extends StatefulWidget {
  const ProviderManagePage({super.key});

  @override
  State<ProviderManagePage> createState() => _ProviderManagePageState();
}

class _ProviderManagePageState extends State<ProviderManagePage> {
  final ProviderService _providerService = ProviderService();
  List<ProviderModel> _providers = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _providers = _providerService.getAllProviders();
    });
  }

  Future<void> _deleteProvider(ProviderModel provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除供应商 "${provider.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _providerService.deleteProvider(provider.id);
      _loadProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商管理'),
      ),
      body: _providers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无供应商',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮添加供应商',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.cloud_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(provider.name),
                    subtitle: Text(
                      provider.isPreset ? '预设供应商' : '自定义供应商',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await Get.toNamed('/providerEdit', arguments: provider);
                            _loadProviders();
                          },
                        ),
                        if (!provider.isPreset)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => _deleteProvider(provider),
                          ),
                      ],
                    ),
                    onTap: () async {
                      await Get.toNamed('/providerEdit', arguments: provider);
                      _loadProviders();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed('/providerEdit');
          _loadProviders();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
