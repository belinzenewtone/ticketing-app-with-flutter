import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/knowledge_article.dart';

final knowledgeProvider = FutureProvider<List<KnowledgeArticle>>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/knowledge-base');
    final list = resp.data as List<dynamic>;
    return list
        .map((e) => KnowledgeArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

class KnowledgeService {
  static Future<KnowledgeArticle> createArticle(
      Map<String, dynamic> data) async {
    try {
      final resp = await ApiClient.instance
          .post('/api/mobile/knowledge-base', data: data);
      return KnowledgeArticle.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<KnowledgeArticle> updateArticle(
      String id, Map<String, dynamic> data) async {
    try {
      final resp = await ApiClient.instance
          .patch('/api/mobile/knowledge-base/$id', data: data);
      return KnowledgeArticle.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<void> deleteArticle(String id) async {
    try {
      await ApiClient.instance.delete('/api/mobile/knowledge-base/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
