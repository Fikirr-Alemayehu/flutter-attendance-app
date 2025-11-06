import 'package:hive/hive.dart';

part 'student_model.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  bool isPresent;

  @HiveField(5)
  final String? courseId;
  @HiveField(6)
  final String? contactId;

  Student({
    required this.id,
    required this.name,
    this.courseId = '',
    this.contactId = '',
    this.phone = '',
    this.address = '',
    this.isPresent = false,
  });
}
