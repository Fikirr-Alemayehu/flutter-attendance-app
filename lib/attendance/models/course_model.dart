import 'package:hive/hive.dart';
part 'course_model.g.dart';

@HiveType(typeId: 3)
class Course extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? instructor;

  Course({required this.id, required this.name, this.instructor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
