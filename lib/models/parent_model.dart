class Parent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> studentIds;
  final String relation; // anne, baba, vasi

  Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentIds,
    required this.relation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'studentIds': studentIds,
      'relation': relation,
    };
  }

  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      studentIds: List<String>.from(map['studentIds']),
      relation: map['relation'],
    );
  }
} 