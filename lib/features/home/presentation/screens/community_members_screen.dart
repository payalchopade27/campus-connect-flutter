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

class _CommunityMembersScreenState
    extends State<CommunityMembersScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> members = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    loading = true;
    setState(() {});

    final memberRows = await supabase
        .from('members')
        .select()
        .eq('team_id', widget.communityId);

    List<Map<String, dynamic>> temp = [];

    for (final member in memberRows) {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', member['user_id'])
          .maybeSingle();

      if (profile != null) {
        temp.add({
          ...profile,
          'role': member['role'],
        });
      }
    }

    members = temp;
    loading = false;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(
        child: Text("No Members"),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  member['full_name'][0],
                ),
              ),
              title: Text(member['full_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member['branch'] ?? ""),
                  Text(member['year'] ?? ""),
                  Text(
                    member['skills'] == null
                        ? ""
                        : (member['skills'] as List).join(", "),
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(member['role']),
              ),
            ),
          );
        },
      ),
    );
  }
}