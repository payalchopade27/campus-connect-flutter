class MemberModel {
  final String userId;
  final String role;

  MemberModel({
    required this.userId,
    required this.role,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      userId: json['user_id'],
      role: json['role'],
    );
  }
}