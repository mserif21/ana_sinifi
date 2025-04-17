class Teacher {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String branch;
  final List<String> classIds;
  final String role;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.branch,
    required this.classIds,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'branch': branch,
      'classIds': classIds,
      'role': role,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      branch: map['branch'],
      classIds: List<String>.from(map['classIds']),
      role: map['role'] ?? 'teacher',
    );
  }
} 