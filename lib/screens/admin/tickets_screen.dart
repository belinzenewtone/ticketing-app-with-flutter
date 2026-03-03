import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/tickets_provider.dart';
import '../../widgets/ticket_card.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  String _status = '';
  String _priority = '';
  String _search = '';
  final _searchCtrl = TextEditingController();

  Map<String, String> get _filters => {
        if (_status.isNotEmpty) 'status': _status,
        if (_priority.isNotEmpty) 'priority': _priority,
        if (_search.isNotEmpty) 'search': _search,
      };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(ticketsProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(ticketsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _search = v.trim()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _FilterDropdown(
                      value: _status,
                      hint: 'All Status',
                      items: kTicketStatuses,
                      onChanged: (v) => setState(() => _status = v ?? ''),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _FilterDropdown(
                      value: _priority,
                      hint: 'All Priority',
                      items: kTicketPriorities,
                      onChanged: (v) => setState(() => _priority = v ?? ''),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ticketsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tickets) => tickets.isEmpty
                  ? const Center(
                      child: Text('No tickets found',
                          style: TextStyle(color: Color(0xFF94A3B8))))
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(ticketsProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: tickets.length,
                        itemBuilder: (ctx, i) => TicketCard(
                          ticket: tickets[i],
                          onTap: () => context
                              .go('/admin/tickets/${tickets[i].id}'),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
        onPressed: () => _showNewTicketDialog(context),
      ),
    );
  }

  void _showNewTicketDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _NewTicketSheet(),
    ).then((_) => ref.invalidate(ticketsProvider));
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        hint: Text(hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        items: [
          DropdownMenuItem(value: '', child: Text(hint)),
          ...items.map((s) => DropdownMenuItem(
              value: s,
              child: Text(_cap(s)))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
}

class _NewTicketSheet extends ConsumerStatefulWidget {
  const _NewTicketSheet();

  @override
  ConsumerState<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends ConsumerState<_NewTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = kTicketCategories.first;
  String _priority = 'medium';
  bool _loading = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await TicketService.createTicket({
        'subject': _subjectCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'priority': _priority,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFDC2626)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: sc,
              children: [
                const Text('New Ticket',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildDropdown('Category', _category, kTicketCategories,
                    (v) => setState(() => _category = v!)),
                const SizedBox(height: 14),
                _buildDropdown('Priority', _priority, kTicketPriorities,
                    (v) => setState(() => _priority = v!)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(_cap(s))))
          .toList(),
      onChanged: onChanged,
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
}
