class Student {
  final String id;
  final String name;
  final String parentName;
  final String? className;
  final String classId;
  final String parentId;
  final DateTime birthDate;
  final String bloodType;
  final List<String> allergies;
  final String? address;

  Student({
    required this.id,
    required this.name,
    required this.parentName,
    this.className,
    required this.classId,
    required this.parentId,
    required this.birthDate,
    required this.bloodType,
    this.allergies = const [],
    this.address,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      parentName: map['parentName'] ?? '',
      className: map['className'],
      classId: map['classId'] ?? '',
      parentId: map['parentId'] ?? '',
      birthDate: map['birthDate'] != null 
          ? DateTime.parse(map['birthDate']) 
          : DateTime.now(),
      bloodType: map['bloodType'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentName': parentName,
      'className': className,
      'classId': classId,
      'parentId': parentId,
      'birthDate': birthDate.toIso8601String(),
      'bloodType': bloodType,
      'allergies': allergies,
      'address': address,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? parentName,
    String? className,
    String? classId,
    String? parentId,
    DateTime? birthDate,
    String? bloodType,
    List<String>? allergies,
    String? address,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      className: className ?? this.className,
      classId: classId ?? this.classId,
      parentId: parentId ?? this.parentId,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      address: address ?? this.address,
    );
  }

  // Tarih formatını düzenleyen yardımcı metod
  String get formattedBirthDate {
    return '${birthDate.day}/${birthDate.month}/${birthDate.year}';
  }
} 