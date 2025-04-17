class ClassRoom {
  final String id;
  final String name;
  final String teacherId;
  final int capacity;
  final List<String> studentIds;

  ClassRoom({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.capacity,
    required this.studentIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'capacity': capacity,
      'studentIds': studentIds,
    };
  }

  factory ClassRoom.fromMap(Map<String, dynamic> map) {
    return ClassRoom(
      id: map['id'],
      name: map['name'],
      teacherId: map['teacherId'],
      capacity: map['capacity'],
      studentIds: List<String>.from(map['studentIds']),
    );
  }
} 