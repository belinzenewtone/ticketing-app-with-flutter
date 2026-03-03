import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../core/api_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _editingName = false;
  bool _editingPassword = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.patch('/api/mobile/me', data: {'name': name});
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        await ref
            .read(authProvider.notifier)
            .updateUser(authState.user.copyWith(name: name));
      }
      setState(() => _editingName = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Name updated'),
              backgroundColor: Color(0xFF059669)));
    } on DioException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiException.fromDio(e).message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePassword() async {
    final pw = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pw.isEmpty) return;
    if (pw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (pw.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiClient.instance
          .patch('/api/mobile/me', data: {'password': pw});
      _passwordCtrl.clear();
      _confirmCtrl.clear();
      setState(() => _editingPassword = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password updated'),
              backgroundColor: Color(0xFF059669)));
    } on DioException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiException.fromDio(e).message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) return const SizedBox();
    final user = authState.user;
    final isAdmin = user.role == 'ADMIN';
    final isStaff = user.isStaff;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF059669),
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(user.email,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFFF3E8FF)
                        : isStaff
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    user.role.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAdmin
                          ? const Color(0xFF7C3AED)
                          : isStaff
                              ? const Color(0xFF059669)
                              : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Edit name section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Display Name',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _editingName = !_editingName;
                            if (_editingName) _nameCtrl.text = user.name;
                          });
                        },
                        child: Text(_editingName ? 'Cancel' : 'Edit'),
                      ),
                    ],
                  ),
                  if (_editingName) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(isDense: true),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _updateName,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Save Name'),
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(user.name,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF64748B))),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Change password section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      TextButton(
                        onPressed: () => setState(
                            () => _editingPassword = !_editingPassword),
                        child:
                            Text(_editingPassword ? 'Cancel' : 'Change'),
                      ),
                    ],
                  ),
                  if (_editingPassword) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          isDense: true),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _updatePassword,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Update Password'),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('••••••••',
                          style: TextStyle(
                              fontSize: 18, color: Color(0xFF64748B))),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Logout
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
            label: const Text('Sign Out',
                style: TextStyle(color: Color(0xFFDC2626))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
