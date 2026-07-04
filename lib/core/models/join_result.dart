/// Result of a join community operation
enum JoinStatus { success, alreadyMember, error }

class JoinResult {
  final JoinStatus status;
  final String? message;

  JoinResult({required this.status, this.message});

  bool get isSuccess => status == JoinStatus.success;
  bool get isAlreadyMember => status == JoinStatus.alreadyMember;
  bool get isError => status == JoinStatus.error;
}

