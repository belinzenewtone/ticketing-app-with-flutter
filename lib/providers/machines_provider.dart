import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/machine.dart';

final machinesProvider = FutureProvider<List<Machine>>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/machines');
    final list = resp.data as List<dynamic>;
    return list
        .map((e) => Machine.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

class MachineService {
  static Future<Machine> createMachine(Map<String, dynamic> data) async {
    try {
      final resp =
          await ApiClient.instance.post('/api/mobile/machines', data: data);
      return Machine.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<Machine> updateMachine(
      String id, Map<String, dynamic> data) async {
    try {
      final resp = await ApiClient.instance
          .patch('/api/mobile/machines/$id', data: data);
      return Machine.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<void> deleteMachine(String id) async {
    try {
      await ApiClient.instance.delete('/api/mobile/machines/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
