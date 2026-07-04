import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_connect/features/home/presentation/screens/communities_screen.dart';
import 'package:campus_connect/features/home/presentation/screens/profile_screen.dart';
import 'community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> trendingFuture;
  late Future<List<Map<String, dynamic>>> teamsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    trendingFuture = supabase
        .from('communities')
        .select()
        .limit(3)
        .order('created_at', ascending: false);

     teamsFuture = supabase
         .from('posts')
         .select('''
           id,
           content,
           post_type,
           created_at,
           profiles!posts_user_id_profiles_fkey (
             full_name,
             branch,
             year
           ),
           communities (
             id,
             name
           )
         ''')
         .eq('post_type', 'looking_for_team')
         .limit(3)
         .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Campus Connect",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_loadData),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _welcomeCard(),
            const SizedBox(height: 24),
            _sectionTitle("Quick Actions"),
            _quickActions(context),
            const SizedBox(height: 28),
            _sectionTitle("Trending Communities"),
            _trendingCommunities(),
            const SizedBox(height: 28),
            _sectionTitle("Looking for Team"),
            _teamPreview(),
          ],
        ),
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Build your next project 🚀",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Find teammates, join communities, and collaborate with students from your campus.",
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        _actionTile(
          icon: Icons.groups_outlined,
          title: "Communities",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommunitiesScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        _actionTile(
          icon: Icons.person_outline,
          title: "Profile",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _trendingCommunities() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyCard("No communities yet");
        }

        return Column(
          children: snapshot.data!.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _dataCard(
                icon: Icons.local_fire_department_rounded,
                title: c['name'],
                subtitle: c['description'] ?? "Active community",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityScreen(
                        communityId: c['id'],
                        communityName: c['name'],
                        description: c['description'],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _teamPreview() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: teamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyCard("No requests found");
        }

        return Column(
          children: snapshot.data!.map((post) {
            final profile = post['profiles'];
            final community = post['communities'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _dataCard(
                icon: Icons.groups_rounded,
                title: profile?['full_name'] ?? "Anonymous",
                subtitle: "Looking for team in ${community?['name'] ?? 'General'}",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                       builder: (_) => CommunityScreen(
                         communityId: post['community_id'],
                         communityName: community?['name'] ?? 'Community',
                       ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ================= REUSABLE =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 38, color: const Color(0xFF4F46E5)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}