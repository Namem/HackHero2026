class User {
  final int id;
  final String name;
  final String email;
  final String role; // "parent" ou "child" — armazenado localmente

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        // Backend retorna first_name, não name
        name: json['name'] ?? json['first_name'] ?? '',
        email: json['email'],
        role: json['role'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}
