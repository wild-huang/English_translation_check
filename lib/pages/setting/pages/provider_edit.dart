import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/services/api_service.dart';
import 'package:trans_flutter/services/model_service.dart';
import 'package:trans_flutter/services/provider_service.dart';

class ProviderEditPage extends StatefulWidget {
  const ProviderEditPage({super.key});

  @override
  State<ProviderEditPage> createState() => _ProviderEditPageState();
}

class _ProviderEditPageState extends State<ProviderEditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProviderService _providerService = ProviderService();
  final ModelService _modelService = ModelService();
  
  ProviderModel? _provider;
  bool _isNew = true;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _endpointController = TextEditingController();
  final TextEditingController _apiPathController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _manualModelController = TextEditingController();
  String _apiFormat = 'openai';
  bool _obscureApiKey = true;
  
  List<String> _models = [];
  bool _isLoadingModels = false;
  String? _modelsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    final args = Get.arguments;
    if (args is ProviderModel) {
      _provider = args;
      _isNew = false;
      _nameController.text = args.name;
      _endpointController.text = args.endpoint;
      _apiPathController.text = args.apiPath;
      _apiKeyController.text = args.apiKey;
      _apiFormat = args.apiFormat;
      _loadModels();
    } else {
      // 默认API路径
      _apiPathController.text = '/chat/completions';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _endpointController.dispose();
    _apiPathController.dispose();
    _apiKeyController.dispose();
    _manualModelController.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    if (_provider == null) return;
    
    setState(() {
      _isLoadingModels = true;
      _modelsError = null;
    });

    try {
      final models = await ApiService().fetchModels(_provider!);
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
      // 自动保存模型到本地
      if (models.isNotEmpty) {
        await _saveModelsToLocal(models);
      }
    } catch (e) {
      setState(() {
        _modelsError = e.toString();
        _isLoadingModels = false;
      });
    }
  }

  Future<void> _saveModelsToLocal(List<String> models) async {
    if (_provider == null) return;
    
    try {
      // 先删除旧模型
      await _modelService.deleteModelsByProvider(_provider!.id);
      // 保存新模型
      final aiModels = models.map((name) => _modelService.createModel(
        providerId: _provider!.id,
        name: name,
        displayName: name,
      )).toList();
      await _modelService.addModels(aiModels);
    } catch (e) {
      debugPrint('保存模型失败: $e');
    }
  }

  void _addManualModel() {
    final modelName = _manualModelController.text.trim();
    if (modelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入模型名称')),
      );
      return;
    }
    
    if (_provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先保存供应商配置')),
      );
      return;
    }

    setState(() {
      if (!_models.contains(modelName)) {
        _models.add(modelName);
      }
    });
    
    // 保存到本地
    _saveModelsToLocal(_models);
    _manualModelController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加模型: $modelName')),
    );
  }

  Future<void> _saveProvider() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入供应商名称')),
      );
      return;
    }

    if (_endpointController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入API端点')),
      );
      return;
    }

    if (_apiPathController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入API路径')),
      );
      return;
    }

    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入API密钥')),
      );
      return;
    }

    // 清理endpoint末尾的斜杠
    String endpoint = _endpointController.text.trim();
    if (endpoint.endsWith('/')) {
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }

    // 确保apiPath以/开头
    String apiPath = _apiPathController.text.trim();
    if (!apiPath.startsWith('/')) {
      apiPath = '/$apiPath';
    }

    if (_isNew) {
      final newProvider = _providerService.createProvider(
        name: _nameController.text,
        apiFormat: _apiFormat,
        endpoint: endpoint,
        apiKey: _apiKeyController.text,
        apiPath: apiPath,
      );
      await _providerService.addProvider(newProvider);
      _provider = newProvider;
      _isNew = false;
      
      // 获取并保存模型列表
      await _loadModels();
    } else {
      _provider!.name = _nameController.text;
      _provider!.apiFormat = _apiFormat;
      _provider!.endpoint = endpoint;
      _provider!.apiPath = apiPath;
      _provider!.apiKey = _apiKeyController.text;
      await _providerService.updateProvider(_provider!);
      
      // 重新获取并保存模型
      await _loadModels();
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? '添加供应商' : '编辑供应商'),
        actions: [
          TextButton(
            onPressed: _saveProvider,
            child: const Text('保存'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '配置'),
            Tab(text: '模型'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 配置 Tab
          _buildConfigTab(theme),
          
          // 模型 Tab
          _buildModelTab(theme),
        ],
      ),
    );
  }

  Widget _buildConfigTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 名称
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '名称',
              hintText: '例如：DeepSeek',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 16),
          
          // API格式
          DropdownButtonFormField<String>(
            value: _apiFormat,
            decoration: InputDecoration(
              labelText: 'API格式',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.api_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: 'openai',
                child: Text('OpenAI 兼容'),
              ),
              DropdownMenuItem(
                value: 'anthropic',
                child: Text('Anthropic'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _apiFormat = value;
                  // 根据API格式设置默认路径
                  if (value == 'anthropic') {
                    _apiPathController.text = '/v1/messages';
                  } else {
                    _apiPathController.text = '/chat/completions';
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // 端点 (Base URL)
          TextField(
            controller: _endpointController,
            decoration: InputDecoration(
              labelText: 'API Base URL',
              hintText: '例如：https://api.deepseek.com/v1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.link_outlined),
              helperText: '包含版本号的Base URL',
            ),
          ),
          const SizedBox(height: 16),
          
          // API路径
          TextField(
            controller: _apiPathController,
            decoration: InputDecoration(
              labelText: 'API路径',
              hintText: '例如：/chat/completions',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.route_outlined),
              helperText: '完整URL = Base URL + API路径',
            ),
          ),
          const SizedBox(height: 16),
          
          // 密钥
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              labelText: 'API密钥',
              hintText: '输入您的API密钥',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureApiKey = !_obscureApiKey;
                  });
                },
              ),
            ),
          ),
          
          // 显示完整URL预览
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '完整API地址预览：',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_endpointController.text.isEmpty ? "https://example.com" : _endpointController.text}${_apiPathController.text.isEmpty ? "/chat/completions" : _apiPathController.text}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelTab(ThemeData theme) {
    if (_isNew) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '请先保存供应商配置',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '保存后将自动获取模型列表',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingModels) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在获取模型列表...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 手动添加模型区域
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '手动添加模型',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualModelController,
                      decoration: InputDecoration(
                        hintText: '输入模型名称',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _addManualModel,
                    icon: const Icon(Icons.add),
                    label: const Text('添加'),
                  ),
                ],
              ),
              if (_modelsError != null) ...[
                const SizedBox(height: 8),
                Text(
                  '自动获取失败，可手动添加模型名称',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '提示：讯飞等部分供应商不支持自动获取模型列表，请手动输入模型ID',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '讯飞模型ID示例：spark、spark-lite、spark-pro、xdeepseekv3 等',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // 模型列表
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '已添加模型 (${_models.length})',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadModels,
                tooltip: '重新获取模型列表',
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _models.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无模型',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '请在上方手动添加模型名称',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    return ListTile(
                      leading: Icon(
                        Icons.smart_toy_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(model),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          setState(() {
                            _models.removeAt(index);
                          });
                          _saveModelsToLocal(_models);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
