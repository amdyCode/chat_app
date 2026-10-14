class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isOnline;
  final DateTime? lastSeen;
  final String statusMessage;
  final List<String> blockedUserIds;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isOnline = false,
    this.lastSeen,
    this.statusMessage = '',
    this.blockedUserIds = const [],
  });

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  bool isUserBlocked(String userId) {
    return blockedUserIds.contains(userId);
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isOnline,
    DateTime? lastSeen,
    String? statusMessage,
    List<String>? blockedUserIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      statusMessage: statusMessage ?? this.statusMessage,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'statusMessage': statusMessage,
      'blockedUserIds': blockedUserIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    DateTime? parsedLastSeen;
    final rawLastSeen = map['lastSeen'];
    if (rawLastSeen is int) {
      parsedLastSeen = DateTime.fromMillisecondsSinceEpoch(rawLastSeen);
    } else if (rawLastSeen != null) {
      try {
        parsedLastSeen = (rawLastSeen as dynamic).toDate() as DateTime?;
      } catch (_) {}
    }

    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'Membre actif',
      isOnline: map['isOnline'] as bool? ?? false,
      lastSeen: parsedLastSeen,
      statusMessage: map['statusMessage'] as String? ?? '',
      blockedUserIds: List<String>.from(map['blockedUserIds'] as List? ?? []),
    );
  }
}
