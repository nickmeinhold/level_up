sealed class User {
  User({required this.id, required this.name, this.email});

  final String id;
  final String name;
  final String? email;

  factory User.fromJsonWithId(String id, Map<String, dynamic> json) {
    switch (json['type']) {
      case 'client':
        return Client.fromJsonWithId(id, json);
      case 'coach':
        return Coach.fromJsonWithId(id, json);
      default:
        throw Exception('Unknown user type: ${json['type']}');
    }
  }
}

class Client extends User {
  Client({required super.id, required super.name, super.email});

  factory Client.fromJsonWithId(String id, Map<String, dynamic> json) =>
      Client(id: id, name: json['name'] ?? 'null', email: json['email']);
}

class Coach extends User {
  Coach({required super.id, required super.name, super.email});

  factory Coach.fromJsonWithId(String id, Map<String, dynamic> json) =>
      Coach(id: id, name: json['name'] ?? 'null', email: json['email']);
}
