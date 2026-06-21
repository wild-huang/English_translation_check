import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:trans_flutter/models/provider_model.dart';
import 'package:trans_flutter/models/check_result.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // 配置Dio以处理旧设备的SSL问题
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  final Dio _dio = Dio();

  Future<TranslationCheckResponse> checkTranslation({
    required ProviderModel provider,
    required String model,
    required String chineseText,
    required String prompt,
    required String translation,
    required bool aiFreeComment,
  }) async {
    final systemPrompt = _buildSystemPrompt(aiFreeComment);
    final userPrompt = _buildUserPrompt(chineseText, prompt, translation);

    if (provider.apiFormat == 'anthropic') {
      return _callAnthropicApi(provider, model, systemPrompt, userPrompt);
    } else {
      return _callOpenAIApi(provider, model, systemPrompt, userPrompt);
    }
  }

  String _buildSystemPrompt(bool aiFreeComment) {
    return '''你是一位专业的英语翻译检查专家，专门针对上海高考英语中译英题型进行检查。

请从以下六个维度对翻译进行详细检查：

1. **基础语法与形态检查**
   - 时态是否正确
   - 单复数是否正确
   - 词性是否正确
   - 主谓一致

2. **词汇与搭配精准度**
   - 词汇选择是否准确
   - 固定搭配是否正确
   - 近义词区分

3. **句法结构与逻辑连贯**
   - 句子结构是否完整
   - 逻辑关系是否清晰
   - 连接词使用是否恰当

4. **文化负载与成语意译**
   - 成语翻译是否恰当
   - 文化概念是否准确传达

5. **语用与语义保真**
   - 原文意思是否完整传达
   - 语气是否恰当
   - 是否有遗漏或添加

6. **书写与格式规范**
   - 拼写是否正确
   - 标点符号是否正确
   - 大小写是否规范

特别注意：
- 如果发现拼写错误，请检查该处表意是否准确
- 修正拼写时，请检查词形是否正确（时态、单复数、词性）

请严格按照以下JSON格式返回结果，不要添加任何其他文字：

{
  "grammar": {
    "summary": "总体评价",
    "items": [
      {"issue": "问题", "explanation": "解释", "suggestion": "建议"}
    ]
  },
  "vocabulary": {
    "summary": "总体评价",
    "items": []
  },
  "syntax": {
    "summary": "总体评价",
    "items": []
  },
  "culture": {
    "summary": "总体评价",
    "items": []
  },
  "pragmatics": {
    "summary": "总体评价",
    "items": []
  },
  "format": {
    "summary": "总体评价",
    "items": []
  },
  "other_issues": {
    "summary": "",
    "items": []
  },
  "suggested_translation": "建议的翻译"
  ${aiFreeComment ? ',"ai_comment": "整体点评"' : ''}
}''';
  }

  String _buildUserPrompt(String chineseText, String prompt, String translation) {
    return '''请检查以下翻译：

**中文原文：**
$chineseText

${prompt.isNotEmpty ? "**翻译提示：**\n$prompt\n" : ""}
**学生翻译：**
$translation

请严格按照JSON格式返回检查结果。''';
  }

  // 构建完整的API URL
  String _buildApiUrl(ProviderModel provider) {
    // 移除endpoint末尾的斜杠
    String endpoint = provider.endpoint;
    if (endpoint.endsWith('/')) {
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    
    // 确保apiPath以/开头
    String apiPath = provider.apiPath;
    if (!apiPath.startsWith('/')) {
      apiPath = '/$apiPath';
    }
    
    return '$endpoint$apiPath';
  }

  // 获取模型列表的URL
  String _buildModelsUrl(ProviderModel provider) {
    // 移除endpoint末尾的斜杠
    String endpoint = provider.endpoint;
    if (endpoint.endsWith('/')) {
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    
    // 直接在endpoint后加/models
    // 用户设置的endpoint已经是完整的base URL（如 https://api.example.com/v1 或 /v2）
    return '$endpoint/models';
  }

  Future<TranslationCheckResponse> _callOpenAIApi(
    ProviderModel provider,
    String model,
    String systemPrompt,
    String userPrompt,
  ) async {
    try {
      final url = _buildApiUrl(provider);
      print('=== Chat API Debug ===');
      print('URL: $url');
      print('Model: $model');
      
      // 清理API Key中的空白字符
      final apiKey = provider.apiKey.trim().replaceAll(RegExp(r'\s+'), '');
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      final content = response.data['choices'][0]['message']['content'];
      return _parseResponse(content);
    } on DioException catch (e) {
      print('=== Chat API Error ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      throw Exception('API调用失败: ${e.response?.data ?? e.message}');
    }
  }

  Future<TranslationCheckResponse> _callAnthropicApi(
    ProviderModel provider,
    String model,
    String systemPrompt,
    String userPrompt,
  ) async {
    try {
      final url = _buildApiUrl(provider);
      debugPrint('API URL: $url');
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': provider.apiKey,
            'anthropic-version': '2023-06-01',
          },
        ),
        data: {
          'model': model,
          'max_tokens': 4096,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userPrompt},
          ],
        },
      );

      final content = response.data['content'][0]['text'];
      debugPrint('API Response: $content');
      return _parseResponse(content);
    } on DioException catch (e) {
      throw Exception('API调用失败: ${e.message}');
    }
  }

  TranslationCheckResponse _parseResponse(String content) {
    try {
      // 尝试提取JSON（AI有时会在JSON前后添加文字）
      String jsonStr = content;
      
      // 尝试找到JSON的开始和结束
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        jsonStr = content.substring(jsonStart, jsonEnd + 1);
      }
      
      debugPrint('Parsing JSON: $jsonStr');
      
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      
      final List<CheckResult> results = [];
      
      // 解析六个维度的检查结果
      final categories = [
        'grammar',
        'vocabulary',
        'syntax',
        'culture',
        'pragmatics',
        'format',
      ];
      
      final titles = [
        '基础语法与形态检查',
        '词汇与搭配精准度',
        '句法结构与逻辑连贯',
        '文化负载与成语意译',
        '语用与语义保真',
        '书写与格式规范',
      ];

      for (int i = 0; i < categories.length; i++) {
        final categoryData = json[categories[i]];
        if (categoryData != null && categoryData is Map) {
          final items = <CheckItem>[];
          if (categoryData['items'] != null && categoryData['items'] is List) {
            for (var item in categoryData['items']) {
              if (item is Map) {
                items.add(CheckItem(
                  issue: item['issue']?.toString() ?? '',
                  explanation: item['explanation']?.toString() ?? '',
                  suggestion: item['suggestion']?.toString() ?? '',
                ));
              }
            }
          }
          results.add(CheckResult(
            category: categories[i],
            title: titles[i],
            content: categoryData['summary']?.toString() ?? '',
            items: items,
          ));
        }
      }

      // 解析其他问题
      if (json['other_issues'] != null && json['other_issues'] is Map) {
        final items = <CheckItem>[];
        if (json['other_issues']['items'] != null && json['other_issues']['items'] is List) {
          for (var item in json['other_issues']['items']) {
            if (item is Map) {
              items.add(CheckItem(
                issue: item['issue']?.toString() ?? '',
                explanation: item['explanation']?.toString() ?? '',
                suggestion: item['suggestion']?.toString() ?? '',
              ));
            }
          }
        }
        results.add(CheckResult(
          category: 'other',
          title: '其他问题',
          content: json['other_issues']['summary']?.toString() ?? '',
          items: items,
        ));
      }

      return TranslationCheckResponse(
        results: results,
        aiComment: json['ai_comment']?.toString(),
        suggestedTranslation: json['suggested_translation']?.toString(),
      );
    } catch (e) {
      debugPrint('Parse error: $e');
      debugPrint('Content: $content');
      // 如果解析失败，返回原始内容作为AI点评
      return TranslationCheckResponse(
        results: [],
        aiComment: content,
        suggestedTranslation: null,
      );
    }
  }

  Future<List<String>> fetchModels(ProviderModel provider) async {
    try {
      if (provider.apiFormat == 'anthropic') {
        return [
          'claude-3-5-sonnet-20241022',
          'claude-3-5-haiku-20241022',
          'claude-3-opus-20240229',
          'claude-3-sonnet-20240229',
          'claude-3-haiku-20240307',
        ];
      }

      // 获取模型列表的URL
      final url = _buildModelsUrl(provider);
      print('=== Fetch Models Debug ===');
      print('URL: $url');
      print('Provider name: ${provider.name}');
      print('Provider id: ${provider.id}');
      print('Provider endpoint: ${provider.endpoint}');
      print('Provider apiPath: ${provider.apiPath}');
      
      // 清理API Key中的空白字符
      final apiKey = provider.apiKey.trim().replaceAll(RegExp(r'\s+'), '');
      print('Provider apiKey length: ${apiKey.length}');
      print('Provider apiKey: $apiKey');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // 尝试不同的响应格式
      if (response.data is Map) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((model) {
            if (model is Map) {
              return model['id']?.toString() ?? model.toString();
            }
            return model.toString();
          }).toList();
        }
      }
      
      // 如果无法解析，返回空列表
      print('无法解析模型列表响应');
      return [];
    } on DioException catch (e) {
      print('=== Fetch Models Error ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Error error: ${e.error}');
      print('Error stackTrace: ${e.stackTrace}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      // 如果获取失败，返回空列表而不是抛出异常
      // 这样用户可以手动输入模型名称
      return [];
    } catch (e, stackTrace) {
      print('=== Fetch Models Unknown Error ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }
}
