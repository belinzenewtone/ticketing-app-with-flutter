import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/task.dart';

final tasksProvider = FutureProvider<List<Task>>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/tasks');
    final list = resp.data as List<dynamic>;
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  },
);

class TaskService {
  static Future<Task> createTask(String title, {String? ticketId}) async {
    try {
      final resp = await ApiClient.instance.post(
        '/api/mobile/tasks',
        data: {
          'title': title,
          if (ticketId != null) 'ticketId': ticketId,
        },
      );
      return Task.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final resp =
          await ApiClient.instance.patch('/api/mobile/tasks/$id', data: data);
      return Task.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<void> deleteTask(String id) async {
    try {
      await ApiClient.instance.delete('/api/mobile/tasks/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
