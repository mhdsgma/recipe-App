class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? password;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      if (password != null) 'password': password,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
      password: jsonUser['password'],
    );
  }
}
