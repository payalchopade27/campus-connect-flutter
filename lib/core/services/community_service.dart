import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_model.dart';
import 'package:campus_connect/core/models/community_model.dart';

class CommunityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Communities I created
  Future<List<Community>> getCreatedCommunities() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('communities')
        .select()
        .eq('created_by', userId);

    return response
        .map<Community>((e) => Community.fromJson(e))
        .toList();
  }

  // Communities I joined
  Future<List<Community>> getJoinedCommunities() async {
    final userId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('communities')
        .select('*, members!inner(team_id)')
        .eq('members.user_id', userId);

    return response
        .map<Community>((e) => Community.fromJson(e))
        .toList();
  }

  Future<void> joinCommunity(String communityId) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    await Supabase.instance.client.from('members').insert({
      'team_id': communityId,
      'user_id': userId,
      'role': 'member',
    });
  }
  Future<List<Community>> getDiscoverCommunities() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    // 1️⃣ Get joined community IDs
    final memberRows = await client
        .from('members')
        .select('team_id')
        .eq('user_id', userId);

    final joinedIds =
    memberRows.map((e) => e['team_id']).toList();

    // 2️⃣ Fetch communities NOT joined
    final query = joinedIds.isEmpty
        ? client.from('communities').select()
        : client.from('communities').select().not(
      'id',
      'in',
      '(${joinedIds.join(',')})',
    );

    final data = await query;

    return data.map<Community>((e) => Community.fromJson(e)).toList();
  }
}