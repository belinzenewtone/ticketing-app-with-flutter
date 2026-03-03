class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? image;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String? ?? json['email'] as String,
        role: json['role'] as String,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        if (image != null) 'image': image,
      };

  bool get isStaff => role == 'ADMIN' || role == 'IT_STAFF';
  bool get isAdmin => role == 'ADMIN';

  User copyWith({String? name, String? image}) => User(
        id: id,
        email: email,
        name: name ?? this.name,
        role: role,
        image: image ?? this.image,
      );
}
