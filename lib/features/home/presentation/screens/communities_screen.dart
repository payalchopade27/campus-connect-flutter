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

  late Future<List<Map<String, dynamic>>> createdFuture;
  late Future<List<Map<String, dynamic>>> joinedFuture;
  late Future<List<Map<String, dynamic>>> discoverFuture;

  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      createdFuture = _getCreated();
      joinedFuture = _getJoined();
      discoverFuture = _getDiscover();
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
    try {
      // First get joined community ids from the members table. Doing this in
      // two steps avoids relying on the client-side "inner" join syntax and
      // guarantees we only fetch communities that actually match the user's
      // membership rows.
      final memberRows = await supabase
          .from('members')
          .select('team_id')
          .eq('user_id', uid);

      final joinedIds = memberRows.map((e) => e['team_id'] as String).toList();

      debugPrint('[_getJoined] joinedIds: $joinedIds');

      // If the user hasn't joined any communities, return an empty list.
      if (joinedIds.isEmpty) return [];

      // Fetch communities with ids in the joined list. Build a quoted id
      // list because the PostgREST 'in' operator expects an SQL-style list
      // like ('id1','id2'). Use the filter() API to pass the operator.
      final quoted = joinedIds.map((e) => "'$e'").join(',');
      final data = await supabase
          .from('communities')
          .select()
          .filter('id', 'in', '($quoted)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Error in _getJoined: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getDiscover() async {
    final uid = supabase.auth.currentUser!.id;

    try {
      final joined = await supabase
          .from('members')
          .select('team_id')
          .eq('user_id', uid);

      final joinedIds = joined.map((e) => e['team_id'] as String).toList();

      debugPrint('[_getDiscover] joinedIds: $joinedIds');

      var query = supabase.from('communities').select();
      
      if (joinedIds.isNotEmpty) {
        // Supabase expects an SQL-style list for the `in`/`not .. in` operator,
        // e.g.: ( 'id1','id2' ). When passing a Dart List directly the client
        // may not build the right query, which can cause the filter to be
        // ignored and return all rows. Build the string explicitly and quote
        // each id to make the `not in` filter work correctly.
        final quoted = joinedIds.map((e) => "'$e'").join(',');
        query = query.not('id', 'in', '($quoted)');
      }

      final data = await query.order('created_at', ascending: false);
      debugPrint('[_getDiscover] found ${data.length} communities to discover');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Error in _getDiscover: $e");
      return [];
    }
  }

  Future<void> _joinCommunity(String communityId) async {
    final result = await communityService.joinCommunityWithCheck(communityId);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Successfully joined community!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(_loadAll);
      } else if (result.isAlreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'You are already a member'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Error joining community'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              Tab(text: "Created"),
              Tab(text: "Joined"),
              Tab(text: "Discover"),
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
             return _communityCard(filtered[index], showJoin);
           },
         );
       },
     );
   }

  /* 🔥 ENHANCED CARD */
  Widget _communityCard(Map<String, dynamic> c, bool showJoin) {
    final name = c['name'] ?? '';
    final desc = c['description'] ?? 'No description provided';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: !showJoin ? () {
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
        } : null,
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
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   if (showJoin)
                     GestureDetector(
                       onTap: () => _joinCommunity(c['id']),
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(14),
                         ),
                         child: const Text("Join", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                       ),
                     )
                   else
                     const Icon(Icons.arrow_forward_ios,
                         size: 16, color: Colors.white70),
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool discover) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              discover ? Icons.explore_rounded : Icons.groups_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              discover
                  ? "No communities to discover yet"
                  : "You don’t have any communities here",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              discover
                  ? "Check back later for new communities to join!"
                  : "Visit the Discover tab to find and join communities 👉",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            if (!discover)
              ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.explore),
                  label: const Text("Go to Discover"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}