import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trans_flutter/models/check_result.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/services/api_service.dart';
import 'package:trans_flutter/services/provider_service.dart';
import 'package:trans_flutter/utils/storage_pref.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chineseController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  
  bool _isChecking = false;
  bool _hasChecked = false;
  bool _aiFreeComment = Pref.aiFreeComment;
  
  TranslationCheckResponse? _checkResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _aiFreeComment = Pref.aiFreeComment;
  }

  @override
  void dispose() {
    _chineseController.dispose();
    _promptController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  ProviderModel? _getSelectedProvider() {
    final providerId = Pref.selectedProviderId;
    if (providerId == null) return null;
    return ProviderService().getProvider(providerId);
  }

  String _getModelDisplayName() {
    final modelId = Pref.selectedModelId;
    if (modelId == null) return '未选择模型';
    return modelId;
  }

  Future<void> _startCheck() async {
    if (_chineseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入中文原文')),
      );
      return;
    }

    if (_translationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入你的翻译')),
      );
      return;
    }

    final provider = _getSelectedProvider();
    if (provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中选择供应商')),
      );
      return;
    }

    final modelId = Pref.selectedModelId;
    if (modelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中选择模型')),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService().checkTranslation(
        provider: provider,
        model: modelId,
        chineseText: _chineseController.text,
        prompt: _promptController.text,
        translation: _translationController.text,
        aiFreeComment: _aiFreeComment,
      );

      setState(() {
        _checkResult = result;
        _hasChecked = true;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isChecking = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _chineseController.clear();
      _promptController.clear();
      _translationController.clear();
      _checkResult = null;
      _hasChecked = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = _getSelectedProvider();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译检查'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed('/setting'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部供应商/模型信息
          if (provider != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.name} / ${_getModelDisplayName()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          
          // 输入区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 中文原文
                  _buildInputCard(
                    title: '中文原文',
                    controller: _chineseController,
                    hintText: '请输入需要翻译的中文原文...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  
                  // 提示词
                  _buildInputCard(
                    title: '提示词（可选）',
                    controller: _promptController,
                    hintText: '输入翻译提示或要求...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  
                  // 你的翻译
                  _buildInputCard(
                    title: '你的翻译',
                    controller: _translationController,
                    hintText: '请输入你的英文翻译...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  
                  // AI自由点评开关
                  SwitchListTile(
                    title: const Text('AI自由点评'),
                    subtitle: const Text('开启后AI给出整体点评'),
                    value: _aiFreeComment,
                    onChanged: (value) {
                      setState(() {
                        _aiFreeComment = value;
                        Pref.aiFreeComment = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  
                  // 按钮区域
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isChecking ? null : _startCheck,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(_isChecking
                              ? '检查中...'
                              : _hasChecked
                                  ? '继续检查'
                                  : '开始检查'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('清空'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 错误信息
                  if (_errorMessage != null)
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  
                  // 检查结果
                  if (_checkResult != null) ...[
                    _buildResultSection(theme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 六个维度的检查结果
        ..._checkResult!.results.map((result) => _buildResultCard(theme, result)),
        
        // AI修改建议
        if (_checkResult!.aiComment != null) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI修改建议',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _checkResult!.aiComment!,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // 建议翻译
        if (_checkResult!.suggestedTranslation != null) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '建议翻译',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _checkResult!.suggestedTranslation!,
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme, CheckResult result) {
    // 如果没有内容和项目，不显示
    if (result.items.isEmpty && result.content.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (result.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(result.content),
            ],
            if (result.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...result.items.map((item) => _buildCheckItem(theme, item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(ThemeData theme, CheckItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.issue.isNotEmpty)
            Text(
              '• ${item.issue}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          if (item.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.explanation,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
          if (item.suggestion.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '建议: ${item.suggestion}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
