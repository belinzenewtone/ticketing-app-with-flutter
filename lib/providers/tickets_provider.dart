import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/ticket.dart';
import '../models/comment.dart';
import '../models/activity.dart';

// ---------------------------------------------------------------------------
// Tickets list (admin — all tickets)
// ---------------------------------------------------------------------------
final ticketsProvider = FutureProvider.family<List<Ticket>, Map<String, String>>(
  (ref, filters) async {
    final params = <String, dynamic>{};
    filters.forEach((k, v) {
      if (v.isNotEmpty) params[k] = v;
    });
    final resp = await ApiClient.instance.get(
      '/api/mobile/tickets',
      queryParameters: params,
    );
    final list = resp.data as List<dynamic>;
    return list.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  },
);

// ---------------------------------------------------------------------------
// Single ticket
// ---------------------------------------------------------------------------
final ticketDetailProvider = FutureProvider.family<Ticket, String>(
  (ref, id) async {
    final resp = await ApiClient.instance.get('/api/mobile/tickets/$id');
    return Ticket.fromJson(resp.data as Map<String, dynamic>);
  },
);

// ---------------------------------------------------------------------------
// Comments for a ticket
// ---------------------------------------------------------------------------
final commentsProvider = FutureProvider.family<List<Comment>, String>(
  (ref, ticketId) async {
    final resp = await ApiClient.instance.get(
      '/api/mobile/comments',
      queryParameters: {'ticket_id': ticketId},
    );
    final list = resp.data as List<dynamic>;
    return list
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

// ---------------------------------------------------------------------------
// Activity log for a ticket
// ---------------------------------------------------------------------------
final activityProvider = FutureProvider.family<List<Activity>, String>(
  (ref, ticketId) async {
    final resp = await ApiClient.instance.get(
      '/api/mobile/activity',
      queryParameters: {'ticket_id': ticketId},
    );
    final list = resp.data as List<dynamic>;
    return list
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

// ---------------------------------------------------------------------------
// Mutations
// ---------------------------------------------------------------------------
class TicketService {
  static Future<Ticket> createTicket(Map<String, dynamic> data) async {
    try {
      final resp =
          await ApiClient.instance.post('/api/mobile/tickets', data: data);
      return Ticket.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<Ticket> updateTicket(
      String id, Map<String, dynamic> data) async {
    try {
      final resp =
          await ApiClient.instance.patch('/api/mobile/tickets/$id', data: data);
      return Ticket.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<void> deleteTicket(String id) async {
    try {
      await ApiClient.instance.delete('/api/mobile/tickets/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<Comment> addComment(
      String ticketId, String content, bool isInternal) async {
    try {
      final resp = await ApiClient.instance.post(
        '/api/mobile/comments',
        data: {
          'ticketId': ticketId,
          'content': content,
          'isInternal': isInternal,
        },
      );
      return Comment.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
