class Community {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  /// Convert Supabase JSON → Dart Object
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}