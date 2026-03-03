import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machines_provider.dart';
import '../../models/machine.dart';
import '../../widgets/status_chip.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machinesAsync = ref.watch(machinesProvider);
    final isStaff = ref.watch(authProvider) is AuthAuthenticated &&
        (ref.watch(authProvider) as AuthAuthenticated).user.isStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(machinesProvider),
          ),
        ],
      ),
      body: machinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (machines) => machines.isEmpty
            ? const Center(
                child: Text('No machine requests',
                    style: TextStyle(color: Color(0xFF94A3B8))))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(machinesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: machines.length,
                  itemBuilder: (ctx, i) => _MachineCard(
                    machine: machines[i],
                    isStaff: isStaff,
                    onUpdate: () => ref.invalidate(machinesProvider),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _NewMachineSheet(),
        ).then((_) => ref.invalidate(machinesProvider)),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  final bool isStaff;
  final VoidCallback onUpdate;

  const _MachineCard(
      {required this.machine,
      required this.isStaff,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isStaff
            ? () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      _MachineDetailSheet(machine: machine, onUpdate: onUpdate),
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.computer_outlined,
                      size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(machine.machineName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B))),
                  ),
                  StatusChip(status: machine.status, small: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(machine.issueDescription,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF475569)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ImportanceChip(importance: machine.importance),
                  const Spacer(),
                  const Icon(Icons.person_outline,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text(machine.requestedByName,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text(
                      DateFormat('MMM d')
                          .format(machine.createdAt.toLocal()),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportanceChip extends StatelessWidget {
  final String importance;

  const _ImportanceChip({required this.importance});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (importance) {
      'critical' => (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
      'high' => (const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
      'medium' => (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      _ => (const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(
        importance[0].toUpperCase() + importance.substring(1),
        style: TextStyle(
            fontSize: 11, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MachineDetailSheet extends ConsumerStatefulWidget {
  final Machine machine;
  final VoidCallback onUpdate;

  const _MachineDetailSheet(
      {required this.machine, required this.onUpdate});

  @override
  ConsumerState<_MachineDetailSheet> createState() =>
      _MachineDetailSheetState();
}

class _MachineDetailSheetState extends ConsumerState<_MachineDetailSheet> {
  late String _status;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.machine.status;
    _notesCtrl.text = widget.machine.resolutionNotes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await MachineService.updateMachine(widget.machine.id, {
        'status': _status,
        'resolutionNotes': _notesCtrl.text.trim(),
      });
      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
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
        initialChildSize: 0.6,
        expand: false,
        builder: (_, sc) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: sc,
            children: [
              Text(widget.machine.machineName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(widget.machine.issueDescription,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF475569))),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: kMachineStatuses
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s[0].toUpperCase() + s.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesCtrl,
                decoration:
                    const InputDecoration(labelText: 'Resolution Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewMachineSheet extends ConsumerStatefulWidget {
  const _NewMachineSheet();

  @override
  ConsumerState<_NewMachineSheet> createState() => _NewMachineSheetState();
}

class _NewMachineSheetState extends ConsumerState<_NewMachineSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _issueCtrl = TextEditingController();
  String _importance = 'medium';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await MachineService.createMachine({
        'machineName': _nameCtrl.text.trim(),
        'issueDescription': _issueCtrl.text.trim(),
        'importance': _importance,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
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
        initialChildSize: 0.6,
        expand: false,
        builder: (_, sc) => Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: sc,
              children: [
                const Text('New Machine Request',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Machine Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _issueCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Issue Description'),
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _importance,
                  decoration:
                      const InputDecoration(labelText: 'Importance'),
                  items: kMachineImportance
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              s[0].toUpperCase() + s.substring(1))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _importance = v ?? _importance),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
