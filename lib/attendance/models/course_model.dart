class Course {
  final String id;
  final String name;
  final String? instructor;

  Course({required this.id, required this.name, this.instructor});

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      name: data['name'] ?? '',
      instructor: data['instructor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'instructor': instructor};
  }
}
