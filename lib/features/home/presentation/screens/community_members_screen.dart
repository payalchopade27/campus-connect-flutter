import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityMembersScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityMembersScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<CommunityMembersScreen> createState() =>
      _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  late Future<List<Map<String, dynamic>>> membersFuture;

  @override
  void initState() {
    super.initState();
    membersFuture = _fetchMembers();
  }

  Future<List<Map<String, dynamic>>> _fetchMembers() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('members')
        .select('role, profiles(id, name, branch, skills)')
        .eq('community_id', widget.communityId);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: Text(
          widget.communityName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyState();
          }

          final members = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final profile = members[index]['profiles'];
              final role = members[index]['role'];

              return _memberCard(
                name: profile['name'] ?? 'Unnamed',
                branch: profile['branch'] ?? 'Unknown',
                skills: profile['skills'] ?? '',
                role: role,
              );
            },
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _memberCard({
    required String name,
    required String branch,
    required String skills,
    required String role,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF4F46E5),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branch,
                  style: const TextStyle(color: Colors.black54),
                ),
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    skills,
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _roleChip(role),
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFEDEBFF) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Member',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? const Color(0xFF4F46E5) : Colors.black54,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No members yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Members will appear when users join",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}