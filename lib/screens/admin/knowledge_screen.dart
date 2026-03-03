import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/knowledge_provider.dart';
import '../../models/knowledge_article.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(authProvider) is AuthAuthenticated &&
        (ref.watch(authProvider) as AuthAuthenticated).user.isStaff;

    final articlesAsync = ref.watch(knowledgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(knowledgeProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search articles...',
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
              onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: articlesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (articles) {
                final filtered = _search.isEmpty
                    ? articles
                    : articles
                        .where((a) =>
                            a.title.toLowerCase().contains(_search) ||
                            a.content.toLowerCase().contains(_search))
                        .toList();

                return filtered.isEmpty
                    ? const Center(
                        child: Text('No articles found',
                            style: TextStyle(color: Color(0xFF94A3B8))))
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(knowledgeProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _ArticleCard(
                            article: filtered[i],
                            isStaff: isStaff,
                            onUpdate: () => ref.invalidate(knowledgeProvider),
                          ),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Article'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _ArticleSheet(),
              ).then((_) => ref.invalidate(knowledgeProvider)),
            )
          : null,
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final KnowledgeArticle article;
  final bool isStaff;
  final VoidCallback onUpdate;

  const _ArticleCard(
      {required this.article, required this.isStaff, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) =>
              _ArticleDetailSheet(article: article, isStaff: isStaff, onUpdate: onUpdate),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.article_outlined,
                      size: 16, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                article.content,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF475569)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy')
                        .format(article.updatedAt.toLocal()),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleDetailSheet extends StatelessWidget {
  final KnowledgeArticle article;
  final bool isStaff;
  final VoidCallback onUpdate;

  const _ArticleDetailSheet(
      {required this.article, required this.isStaff, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      expand: false,
      builder: (_, sc) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: sc,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(article.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                if (isStaff)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) =>
                                _ArticleSheet(article: article),
                          ).then((_) => onUpdate());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFDC2626)),
                        onPressed: () async {
                          await KnowledgeService.deleteArticle(article.id);
                          onUpdate();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(article.category,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF059669))),
            ),
            const SizedBox(height: 16),
            Text(article.content,
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF1E293B), height: 1.6)),
            const SizedBox(height: 16),
            Text(
              'By ${article.authorName} • ${DateFormat('MMM d, yyyy').format(article.createdAt.toLocal())}',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleSheet extends ConsumerStatefulWidget {
  final KnowledgeArticle? article;

  const _ArticleSheet({this.article});

  @override
  ConsumerState<_ArticleSheet> createState() => _ArticleSheetState();
}

class _ArticleSheetState extends ConsumerState<_ArticleSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  String _category = 'general';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.article?.title ?? '');
    _contentCtrl =
        TextEditingController(text: widget.article?.content ?? '');
    _category = widget.article?.category ?? 'general';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'category': _category,
      };
      if (widget.article != null) {
        await KnowledgeService.updateArticle(widget.article!.id, data);
      } else {
        await KnowledgeService.createArticle(data);
      }
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
        initialChildSize: 0.85,
        expand: false,
        builder: (_, sc) => Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: sc,
              children: [
                Text(
                    widget.article != null
                        ? 'Edit Article'
                        : 'New Article',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 8,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['general', 'hardware', 'software', 'network', 'security', 'account']
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s[0].toUpperCase() + s.substring(1))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v ?? _category),
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
                      : Text(widget.article != null
                          ? 'Save Changes'
                          : 'Publish Article'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
