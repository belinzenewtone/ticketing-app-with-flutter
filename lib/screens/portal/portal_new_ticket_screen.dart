import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/portal_provider.dart';

class PortalNewTicketScreen extends ConsumerStatefulWidget {
  const PortalNewTicketScreen({super.key});

  @override
  ConsumerState<PortalNewTicketScreen> createState() =>
      _PortalNewTicketScreenState();
}

class _PortalNewTicketScreenState
    extends ConsumerState<PortalNewTicketScreen> {
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
      await PortalService.createTicket({
        'subject': _subjectCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'priority': _priority,
      });
      ref.invalidate(portalTicketsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket submitted successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/portal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: const Color(0xFFDC2626)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Ticket'),
        leading: BackButton(
            onPressed: () => context.go('/portal')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Help header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF059669), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Describe your issue in detail so our IT team can assist you quickly.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  hintText: 'Brief description of the issue',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Provide more details about the issue...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please describe the issue' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: kTicketCategories
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(_formatOption(s))))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: kTicketPriorities
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(_formatOption(s))))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v ?? _priority),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_outlined),
                  label: Text(_loading ? 'Submitting...' : 'Submit Ticket'),
                  onPressed: _loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatOption(String s) => s.isEmpty
      ? s
      : s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
}
