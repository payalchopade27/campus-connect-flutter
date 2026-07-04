import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityPostsScreen extends StatefulWidget {
  final String communityId;

  const CommunityPostsScreen({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityPostsScreen> createState() =>
      _CommunityPostsScreenState();
}

class _CommunityPostsScreenState extends State<CommunityPostsScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = _loadPosts();
  }

  Future<List<Map<String, dynamic>>> _loadPosts() async {
    final data = await supabase
        .from('posts')
        .select('''
          id,
          content,
          post_type,
          created_at,
          profiles (
            full_name,
            branch,
            year
          )
        ''')
        .eq('community_id', widget.communityId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final post = snapshot.data![index];
            final profile = post['profiles'];

            return _postCard(
              name: profile['full_name'],
              branch: profile['branch'],
              year: profile['year'],
              content: post['content'],
              looking: post['post_type'] == 'looking_for_team',
            );
          },
        );
      },
    );
  }

  Widget _postCard({
    required String name,
    required String branch,
    required String year,
    required String content,
    required bool looking,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              _avatar(name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700)),
                    Text(
                      "$branch • $year",
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (looking) _lookingChip(),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _lookingChip() => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEBFF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      "Looking for Team",
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4F46E5),
      ),
    ),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.only(top: 80),
    child: Column(
      children: const [
        Icon(Icons.forum_outlined,
            size: 56, color: Color(0xFF4F46E5)),
        SizedBox(height: 16),
        Text(
          "No posts yet",
          style:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text(
          "Start the first discussion 🚀",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}