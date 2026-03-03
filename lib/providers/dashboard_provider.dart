import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/dashboard_stats.dart';

final dashboardProvider = FutureProvider<DashboardStats>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/dashboard');
    return DashboardStats.fromJson(resp.data as Map<String, dynamic>);
  },
);
