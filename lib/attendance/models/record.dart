import 'package:hive/hive.dart';

part 'record.g.dart';

@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  bool isPresent;

  AttendanceRecord({
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.isPresent,
  });
}
