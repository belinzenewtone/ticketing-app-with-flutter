import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/user.dart';

final staffProvider = FutureProvider<List<User>>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/staff');
    final list = resp.data as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  },
);
