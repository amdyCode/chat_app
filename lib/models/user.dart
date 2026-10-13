class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isOnline;
  final String statusMessage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isOnline = false,
    this.statusMessage = '',
  });

  String get initial {
    if (name.trim().isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }
}