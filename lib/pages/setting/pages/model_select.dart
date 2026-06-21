import 'package:flutter/material.dart';
import 'package:trans_flutter/models/ai_model.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/services/model_service.dart';
import 'package:trans_flutter/services/provider_service.dart';
import 'package:trans_flutter/utils/storage_pref.dart';

class ModelSelectPage extends StatefulWidget {
  const ModelSelectPage({super.key});

  @override
  State<ModelSelectPage> createState() => _ModelSelectPageState();
}

class _ModelSelectPageState extends State<ModelSelectPage> {
  final ProviderService _providerService = ProviderService();
  final ModelService _modelService = ModelService();
  
  List<ProviderModel> _providers = [];
  Map<String, List<AIModel>> _modelsByProvider = {};
  String? _selectedModelId;
  String? _selectedProviderId;

  @override
  void initState() {
    super.initState();
    _selectedModelId = Pref.selectedModelId;
    _selectedProviderId = Pref.selectedProviderId;
    _loadData();
  }

  void _loadData() {
    final providers = _providerService.getAllProviders();
    final Map<String, List<AIModel>> modelsByProvider = {};
    
    for (var provider in providers) {
      final models = _modelService.getModelsByProvider(provider.id);
      if (models.isNotEmpty) {
        modelsByProvider[provider.id] = models;
      }
    }

    setState(() {
      _providers = providers;
      _modelsByProvider = modelsByProvider;
    });
  }

  void _selectModel(AIModel model) {
    setState(() {
      _selectedModelId = model.id;
      _selectedProviderId = model.providerId;
      Pref.selectedModelId = model.name;  // 保存模型名称而不是ID
      Pref.selectedProviderId = model.providerId;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择: ${model.displayName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 检查是否有模型
    bool hasModels = _modelsByProvider.values.any((models) => models.isNotEmpty);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('模型选择'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: !hasModels
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无可用模型',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请先在"导入"中配置供应商',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '配置后需要点击供应商编辑页面的"模型"标签',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '系统会自动获取并保存模型列表',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新'),
                  ),
                ],
              ),
            )
          : ListView(
              children: _providers.map((provider) {
                final models = _modelsByProvider[provider.id] ?? [];
                if (models.isEmpty) return const SizedBox.shrink();
                
                return _buildProviderSection(theme, provider, models);
              }).toList(),
            ),
    );
  }

  Widget _buildProviderSection(
    ThemeData theme,
    ProviderModel provider,
    List<AIModel> models,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                provider.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${models.length} 个模型',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...models.map((model) => _buildModelTile(theme, model)),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildModelTile(ThemeData theme, AIModel model) {
    final isSelected = _selectedModelId == model.name && 
                       _selectedProviderId == model.providerId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          Icons.smart_toy_outlined,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          model.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            : null,
        onTap: () => _selectModel(model),
      ),
    );
  }
}
