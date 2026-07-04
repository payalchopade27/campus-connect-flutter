import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'community_members_screen.dart';
import 'community_posts_screen.dart';
import 'create_post_screen.dart';
import 'package:campus_connect/core/services/community_service.dart';

class CommunityScreen extends StatefulWidget {
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
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isMember = false;
  bool isLoadingMembership = true;
  String? creatorId;
  final communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  Future<void> _loadCommunityData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // 1. Check membership
      final memberResponse = await supabase
          .from('members')
          .select()
          .eq('team_id', widget.communityId)
          .eq('user_id', userId)
          .maybeSingle();

      // 2. Get community details (for creator check)
      final communityResponse = await supabase
          .from('communities')
          .select('created_by')
          .eq('id', widget.communityId)
          .single();

      if (mounted) {
        setState(() {
          isMember = memberResponse != null;
          creatorId = communityResponse['created_by'];
          isLoadingMembership = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingMembership = false);
      }
    }
  }

  Future<void> _joinCommunity() async {
    setState(() => isLoadingMembership = true);

    final result = await communityService.joinCommunityWithCheck(widget.communityId);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully joined community!"), backgroundColor: Colors.green),
        );
        _loadCommunityData();
      } else if (result.isAlreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "You are already a member of this community"), backgroundColor: Colors.orange),
        );
        setState(() => isLoadingMembership = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "Error joining community"), backgroundColor: Colors.red),
        );
        setState(() => isLoadingMembership = false);
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final supabase = Supabase.instance.client;
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Member"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search by name...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        setDialogState(() => isSearching = true);
                        final term = searchController.text.trim();
                        if (term.isNotEmpty) {
                          final response = await supabase
                              .from('profiles')
                              .select()
                              .ilike('full_name', '%$term%')
                              .limit(10);
                          setDialogState(() {
                            searchResults = List<Map<String, dynamic>>.from(response);
                            isSearching = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isSearching)
                  const CircularProgressIndicator()
                else if (searchResults.isEmpty)
                  const Text("No users found")
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          title: Text(user['full_name'] ?? 'Unknown'),
                          subtitle: Text(user['branch'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4F46E5)),
                            onPressed: () async {
                               try {
                                 // Create a temporary instance with the specific user_id
                                 // (We need to add the selected user, not current user)
                                 await supabase.from('members').insert({
                                   'team_id': widget.communityId,
                                   'user_id': user['user_id'],
                                   'role': 'member',
                                 });
                                 Navigator.pop(context);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text("Member added successfully!"), backgroundColor: Colors.green),
                                 );
                                 _loadCommunityData();
                               } catch (e) {
                                 final err = e.toString().toLowerCase();
                                 if (err.contains('duplicate') || err.contains('already') || err.contains('23505')) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(content: Text("Error: User is already a member"), backgroundColor: Colors.orange),
                                   );
                                 } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text("Error adding member: $e"), backgroundColor: Colors.red),
                                   );
                                 }
                               }
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isCreator = creatorId == supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: const BackButton(),
        title: Text(
          widget.communityName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: _showAddMemberDialog,
            ),
          if (!isLoadingMembership && !isMember)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: ElevatedButton(
                onPressed: _joinCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Join"),
              ),
            ),
        ],
      ),

      /// ➕ CREATE POST BUTTON (Only for members)
      floatingActionButton: !isLoadingMembership && isMember
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4F46E5),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(
                      communityId: widget.communityId,
                    ),
                  ),
                );
                if (result == true) {
                  setState(() {}); // Reload posts
                }
              },
            )
          : null,
      body: isLoadingMembership
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// 🔷 HEADER
                _header(),

                const SizedBox(height: 28),

                if (isMember) ...[
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
                            communityName: widget.communityName,
                            communityId: widget.communityId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  /// 📝 POSTS
                  _sectionTitle("Posts"),

                  /// 👉 POSTS LIST
                  SizedBox(
                    height: 500,
                    child: CommunityPostsScreen(
                      communityId: widget.communityId,
                      key: UniqueKey(), // Force rebuild to reload posts
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "Private Community",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Join this community to see posts and members",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _joinCommunity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Join Community",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  // ================= UI PARTS =================

  Widget _header() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.communityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description ?? "A place to build teams & collaborate 🚀",
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
