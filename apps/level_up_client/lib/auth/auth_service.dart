class AuthService {
  AuthService();

  void update({String? email, String? name}) {
    _email = email ?? _email;
    _name = name ?? _name;
  }

  String? _email;
  String? _name;
}
