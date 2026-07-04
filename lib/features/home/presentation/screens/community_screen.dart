import 'package:flutter/material.dart';
import 'community_members_screen.dart';
import 'community_posts_screen.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  final String communityId;
  final String communityName;
  final String? description;

  const CommunityScreen({
    super.key,
    required this.communityId,
    required this.communityName,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          communityName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      /// ➕ CREATE POST BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                communityId: communityId,
              ),
            ),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔷 HEADER
          _header(),

          const SizedBox(height: 28),

          /// 👥 MEMBERS
          _sectionTitle("Members"),
          _actionCard(
            context,
            icon: Icons.people_outline,
            title: "View Community Members",
            subtitle: "See all students in this community",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunityMembersScreen(
                    communityName: communityName,
                    communityId: communityId,

                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          /// 📝 POSTS
          _sectionTitle("Posts"),

          /// 👉 POSTS LIST
          // Wrapped in a fixed height or use shrinkWrap in CommunityPostsScreen
          // to prevent layout crashes inside a ListView.
          SizedBox(
            height: 500, // Adjust height as needed or use a CustomScrollView
            child: CommunityPostsScreen(
              communityId: communityId,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            communityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description ?? "A place to build teams & collaborate 🚀",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF4F46E5)),
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
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}