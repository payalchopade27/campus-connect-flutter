import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_model.dart';

class MemberService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MemberModel>> getMembers(String communityId) async {
    final response = await _supabase
        .from('members')
        .select()
        .eq('team_id', communityId);

    return response
        .map<MemberModel>((e) => MemberModel.fromJson(e))
        .toList();
  }
}