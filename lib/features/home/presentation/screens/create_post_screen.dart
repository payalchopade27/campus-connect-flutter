import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostScreen extends StatefulWidget {
  final String communityId;

  const CreatePostScreen({super.key, required this.communityId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _skills = TextEditingController();

  bool loading = false;

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;

    setState(() => loading = true);

    final supabase = Supabase.instance.client;

    await supabase.from('posts').insert({
      'community_id': widget.communityId,
      'user_id': supabase.auth.currentUser!.id,
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'skills': _skills.text.split(','),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "Post title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skills,
              decoration: const InputDecoration(
                labelText: "Skills (comma separated)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}