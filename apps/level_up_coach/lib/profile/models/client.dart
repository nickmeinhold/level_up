class Client {
  Client({required this.id, required this.name, required this.avatarUrl});

  final String id;
  final String name;
  final String avatarUrl;

  factory Client.fromJsonWithId({
    required String id,
    required Map<String, Object?> json,
  }) {
    return Client(
      id: id,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {'id': id, 'name': name, 'avatarUrl': avatarUrl};
  }
}
