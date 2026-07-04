import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> createdFuture;
  late Future<List<Map<String, dynamic>>> joinedFuture;
  late Future<List<Map<String, dynamic>>> discoverFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  void _loadAll() {
    createdFuture = _getCreated();
    joinedFuture = _getJoined();
    discoverFuture = _getDiscover();
  }

  /// ------------------ DATA ------------------

  Future<List<Map<String, dynamic>>> _getCreated() async {
    final uid = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('communities')
        .select()
        .eq('created_by', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> _getJoined() async {
    final uid = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('community_members')
        .select('communities(*)')
        .eq('user_id', uid);

    return data
        .map<Map<String, dynamic>>((e) => e['communities'])
        .where((e) => e != null)
        .toList();
  }

  /// 🔴 FIXED NULL ERROR HERE
  Future<List<Map<String, dynamic>>> _getDiscover() async {
    final uid = supabase.auth.currentUser!.id;

    final joined = await supabase
        .from('community_members')
        .select('community_id')
        .eq('user_id', uid);

    final joinedIds =
    joined.map((e) => e['community_id']).toList();

    final query = supabase.from('communities').select();

    if (joinedIds.isNotEmpty) {
      query.not('id', 'in', '(${joinedIds.join(",")})');
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _joinCommunity(String id) async {
    await supabase.from('community_members').insert({
      'community_id': id,
      'user_id': supabase.auth.currentUser!.id,
    });
    setState(_loadAll);
  }

  /// ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Communities",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4F46E5),
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Created"),
            Tab(text: "Joined"),
            Tab(text: "Discover"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text("Create"),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _communityList(createdFuture, showJoin: false),
          _communityList(joinedFuture, showJoin: false),
          _communityList(discoverFuture, showJoin: true),
        ],
      ),
    );
  }

  Widget _communityList(
      Future<List<Map<String, dynamic>>> future, {
        required bool showJoin,
      }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyState(showJoin);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _communityCard(snapshot.data![index], showJoin);
          },
        );
      },
    );
  }

  /// 🔥 COMPLETELY NEW CARD DESIGN
  Widget _communityCard(Map<String, dynamic> c, bool showJoin) {
    final name = c['name'] ?? '';
    final desc = c['description'] ?? 'No description';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Colors.white70 != null
                ? const TextStyle(color: Colors.white70)
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showJoin)
                ElevatedButton(
                  onPressed: () => _joinCommunity(c['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Join"),
                )
              else
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
            ],
          )
        ],
      ),
    );
  }

  Widget _emptyState(bool discover) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              discover ? Icons.explore : Icons.groups,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              discover
                  ? "No communities to discover"
                  : "Nothing here yet",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}