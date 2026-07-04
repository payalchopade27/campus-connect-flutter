import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/community_service.dart';
import '../../../../core/models/community_model.dart';
import 'community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final CommunityService _service = CommunityService();

  late Future<List<Community>> created;
  late Future<List<Community>> joined;
  late Future<List<Community>> discover;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      created = _service.getCreatedCommunities();
      joined = _service.getJoinedCommunities();
      discover = _service.getDiscoverCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: const Text("Communities"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
          );
          _reload();
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            _section("Created by You", created, false),
            const SizedBox(height: 32),
            _section("Joined Communities", joined, false),
            const SizedBox(height: 32),
            _section("Discover Communities", discover, true),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Future<List<Community>> future, bool showJoin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        FutureBuilder<List<Community>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Nothing here yet", style: TextStyle(color: Colors.grey));
            }
            return Column(
              children: snapshot.data!.map((c) => _communityCard(c, showJoin)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _communityCard(Community c, bool showJoin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityScreen(
                communityId: c.id,
                communityName: c.name,
                description: c.description,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(c.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              if (showJoin)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await _service.joinCommunity(c.id);
                    setState(_reload); // refresh lists
                  },
                  child: const Text("Join"),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// ➕ CREATE COMMUNITY SCREEN (Consolidated)
class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a community name")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('communities').insert({
        'name': name,
        'description': desc,
        'created_by': supabase.auth.currentUser!.id,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Community")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Community Name", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder())),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                onPressed: _isLoading ? null : _handleCreate,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Create Community", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}