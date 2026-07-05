import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'community_screen.dart';
import 'create_community_screen.dart';
import 'package:campus_connect/core/services/community_service.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;
  final communityService = CommunityService();

  late Future<List<Map<String, dynamic>>> communitiesFuture;
  late Future<List<Map<String, dynamic>>> joinedFuture;


  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadAll() {
    setState(() {
      communitiesFuture = _getCreated();
      joinedFuture = _getJoined();
    });
  }

  /* ---------------- DATA ---------------- */

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

    print("Current User: $uid");

    final memberRows = await supabase
        .from('members')
        .select('team_id')
        .eq('user_id', uid);

    print("Member Rows:");
    print(memberRows);

    if (memberRows.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> communities = [];

    for (final row in memberRows) {
      print("Loading community: ${row['team_id']}");

      final community = await supabase
          .from('communities')
          .select()
          .eq('id', row['team_id'])
          .single();

      print("Found: ${community['name']}");

      communities.add(community);
    }

    print("Final Communities:");
    print(communities);

    return communities;
  }

  /// Filter communities by search query
  List<Map<String, dynamic>> _filterCommunities(List<Map<String, dynamic>> communities) {
    if (searchQuery.isEmpty) return communities;
    return communities
        .where((c) => (c['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Communities",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Build teams • Find collaborators • Grow together",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
           bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Communities"),
              Tab(text: "Joined Communities"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add),
        label: const Text("Create Community"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
          );
          if (result == true) {
            setState(_loadAll);
          }
        },
      ),
       body: TabBarView(
        controller: _tabController,
        children: [
          _communityList(communitiesFuture),
          _communityList(joinedFuture),
        ],
      ),
    );
  }



  Widget _communityList(
      Future<List<Map<String, dynamic>>> future, {
        bool showJoin = false,
      }) {
     return FutureBuilder<List<Map<String, dynamic>>>(
       future: future,
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
         if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return _emptyState();
         }

         // Apply search filter
         final filtered = _filterCommunities(snapshot.data!);

         if (filtered.isEmpty && searchQuery.isNotEmpty) {
           return Center(
             child: Padding(
               padding: const EdgeInsets.all(40),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     Icons.search_off,
                     size: 72,
                     color: Colors.grey.shade400,
                   ),
                   const SizedBox(height: 16),
                   const Text(
                     "No communities found",
                     textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 16, color: Colors.grey),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     "Try searching with different keywords",
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 14, color: Colors.black54),
                   ),
                 ],
               ),
             ),
           );
         }

         return ListView.builder(
           padding: const EdgeInsets.all(20),
           itemCount: filtered.length,
           itemBuilder: (context, index) {
             return _communityCard(filtered[index], showJoin: showJoin);
           },
         );
       },
     );
   }

  /* 🔥 ENHANCED CARD */
  Widget _communityCard(Map<String, dynamic> c, {bool showJoin = false}) {
    final name = c['name'] ?? '';
    final desc = c['description'] ?? 'No description provided';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityScreen(
                communityId: c['id'],
                communityName: name,
                description: desc,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Communities Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create your first community and invite your teammates.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}