import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_connect/core/models/community_model.dart';
import '../models/join_result.dart';

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

  /// Robust join method with pre-check for existing membership.
  /// Returns JoinResult with status: success, alreadyMember, or error.
  Future<JoinResult> joinCommunityWithCheck(String communityId) async {
    final userId = _supabase.auth.currentUser!.id;

    try {
      // 1️⃣ Check if user is already a member
      final existing = await _supabase
          .from('members')
          .select()
          .eq('team_id', communityId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return JoinResult(
          status: JoinStatus.alreadyMember,
          message: 'You are already a member of this community',
        );
      }

      // 2️⃣ User is not a member, so insert into members table
      await _supabase.from('members').insert({
        'team_id': communityId,
        'user_id': userId,
        'role': 'member',
      });

      return JoinResult(
        status: JoinStatus.success,
        message: 'Successfully joined community!',
      );
    } catch (e) {
      // Handle database errors (e.g., FK constraint, unique constraint)
      final err = e.toString().toLowerCase();
      if (err.contains('duplicate') || err.contains('already') || err.contains('23505')) {
        return JoinResult(
          status: JoinStatus.alreadyMember,
          message: 'You are already a member of this community',
        );
      }
      return JoinResult(
        status: JoinStatus.error,
        message: 'Error joining community: $e',
      );
    }
  }
  Future<List<Community>> getDiscoverCommunities() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    // 1️⃣ Get joined community IDs
    final memberRows = await client
        .from('members')
        .select('team_id')
        .eq('user_id', userId);

    final joinedIds = memberRows.map((e) => e['team_id'] as String).toList();

    // 2️⃣ Fetch communities NOT joined. Build a quoted id list because
    // Supabase expects an SQL-style list for the `in` operator: ('id1','id2')
    final query = joinedIds.isEmpty
        ? client.from('communities').select()
        : client.from('communities').select().not(
            'id',
            'in',
            '(${joinedIds.map((e) => "'$e'").join(',')})',
           );

     final data = await query;

     return data.map<Community>((e) => Community.fromJson(e)).toList();
   }

   /// Check if the current user is a member of a community.
   Future<bool> isMember(String communityId) async {
     try {
       final userId = _supabase.auth.currentUser!.id;
       final result = await _supabase
           .from('members')
           .select()
           .eq('team_id', communityId)
           .eq('user_id', userId)
           .maybeSingle();
       return result != null;
     } catch (e) {
       return false;
     }
   }
 }
