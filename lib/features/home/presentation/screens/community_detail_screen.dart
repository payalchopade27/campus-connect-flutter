import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_connect/core/services/community_service.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  final String name;
  final String description;

  const CommunityDetailScreen({
    super.key,
    required this.communityId,
    required this.name,
    required this.description,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool isMember = false;
  bool isLoading = true;
  final communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('members')
        .select()
        .eq('team_id', widget.communityId)
        .eq('user_id', userId)
        .maybeSingle();

    setState(() {
      isMember = response != null;
      isLoading = false;
    });
  }

  Future<void> _joinCommunity() async {
    final result = await communityService.joinCommunityWithCheck(widget.communityId);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully joined community!"), backgroundColor: Colors.green),
        );
        setState(() => isMember = true);
      } else if (result.isAlreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "You are already a member"), backgroundColor: Colors.orange),
        );
        setState(() => isMember = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "Error joining community"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isMember ? null : _joinCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isMember ? 'Already Joined' : 'Join Community',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}