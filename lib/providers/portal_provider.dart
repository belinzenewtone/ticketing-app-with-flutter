import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/ticket.dart';

// ---------------------------------------------------------------------------
// Portal tickets (user's own tickets)
// ---------------------------------------------------------------------------
final portalTicketsProvider = FutureProvider<List<Ticket>>(
  (ref) async {
    final resp = await ApiClient.instance.get('/api/mobile/portal/tickets');
    final list = resp.data as List<dynamic>;
    return list.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  },
);

class PortalService {
  static Future<Ticket> createTicket(Map<String, dynamic> data) async {
    try {
      final resp = await ApiClient.instance
          .post('/api/mobile/portal/tickets', data: data);
      return Ticket.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
