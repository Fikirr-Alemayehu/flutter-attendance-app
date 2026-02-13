import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String studentId;
  final String courseId;
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.isPresent,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      studentId: data['studentId'] ?? '',
      courseId: data['courseId'] ?? '',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      isPresent: data['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
