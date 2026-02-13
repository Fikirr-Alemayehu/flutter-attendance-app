import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/student_model.dart';
import '../models/course_model.dart';
import '../models/record.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription? _studentsSub;
  StreamSubscription? _coursesSub;

  List<Student> students = [];
  List<Course> courses = [];

  String? selectedCourseId;
  bool loading = true;

  HomeViewModel() {
    _studentsSub = _db.collection('students').snapshots().listen((snapshot) {
      students = snapshot.docs
          .map((doc) => Student.fromMap(doc.id, doc.data() ?? {}))
          .toList();
      notifyListeners();
    });

    _coursesSub = _db.collection('courses').snapshots().listen((snapshot) {
      courses = snapshot.docs
          .map((doc) => Course.fromMap(doc.id, doc.data() ?? {}))
          .toList();
      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _coursesSub?.cancel();
    super.dispose();
  }

  void setSelectedCourse(String? courseId) {
    selectedCourseId = courseId;
    notifyListeners();
  }

  Course? get selectedCourse {
    if (selectedCourseId == null) return null;
    try {
      return courses.firstWhere((c) => c.id == selectedCourseId);
    } catch (e) {
      return null;
    }
  }

  Stream<AttendanceRecord?> attendanceForStudent(String studentId) {
    if (selectedCourseId == null) return const Stream.empty();

    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";

    return _db
        .collection('attendance')
        .doc('$selectedCourseId-$studentId-$dateKey')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = doc.data();
          if (data == null) return null;
          return AttendanceRecord.fromMap(data);
        });
  }

  Future<void> toggleAttendance(String studentId) async {
    if (selectedCourseId == null) return;

    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";
    final docId = '$selectedCourseId-$studentId-$dateKey';

    final ref = _db.collection('attendance').doc(docId);
    final snap = await ref.get();

    if (snap.exists) {
      final data = snap.data();
      if (data != null) {
        final current = AttendanceRecord.fromMap(data);
        await ref.update({
          'isPresent': !current.isPresent,
          'courseId': selectedCourseId,
        });
      }
    } else {
      await ref.set(
        AttendanceRecord(
          studentId: studentId,
          courseId: selectedCourseId!,
          date: today,
          isPresent: true,
        ).toMap(),
      );
    }
  }

  Future<void> addCourse(String name) async {
    await _db.collection('courses').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addStudentWithDetails(
    String name,
    String phone,
    String address,
    String? contactId,
  ) async {
    await _db.collection('students').add({
      'name': name,
      'phone': phone,
      'address': address,
      'contactId': contactId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editStudent(
    String id,
    String name,
    String phone,
    String address,
    String? contactId,
  ) async {
    await _db.collection('students').doc(id).update({
      'name': name,
      'phone': phone,
      'address': address,
      'contactId': contactId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AttendanceRecord>> attendanceByDate(
    DateTime date, {
    String? courseId,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    Query query = _db
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end);

    if (courseId != null && courseId.isNotEmpty) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data == null) return null;
            return AttendanceRecord.fromMap(data as Map<String, dynamic>);
          })
          .whereType<AttendanceRecord>()
          .toList();
    });
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection('students').doc(id).delete();

    final records = await _db
        .collection('attendance')
        .where('studentId', isEqualTo: id)
        .get();

    for (var doc in records.docs) {
      await doc.reference.delete();
    }
  }

  Future<Map<String, List<AttendanceRecord>>> getStudentAttendanceHistory(
    String studentId, {
    String? courseId,
  }) async {
    Query query = _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId);

    if (courseId != null && courseId.isNotEmpty) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    final snapshot = await query.get();
    final history = <String, List<AttendanceRecord>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data == null) continue; // Skip bad docs
      final record = AttendanceRecord.fromMap(data as Map<String, dynamic>);
      history.putIfAbsent(record.courseId, () => []).add(record);
    }

    return history;
  }

  Future<void> exportAttendancePDF(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;

    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansEthiopic-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(font: ttf),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'የተማሪ መገኘት ሪፖርት', // Amharic title example
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  headers: ['Student', 'Course', 'Status', 'Date'],
                  data: records.map((record) {
                    final student = students.firstWhere(
                      (s) => s.id == record.studentId,
                      orElse: () => Student(
                        id: record.studentId,
                        name: record.studentId,
                        phone: '',
                        address: '',
                        contactId: null,
                      ),
                    );

                    final course = courses.firstWhere(
                      (c) => c.id == record.courseId,
                      orElse: () =>
                          Course(id: record.courseId, name: record.courseId),
                    );

                    return [
                      student.name,
                      course.name,
                      record.isPresent ? "Present" : "Absent",
                      record.date.toLocal().toString().split(' ')[0],
                    ];
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> updateCourse(String id, String name) async {
    await _db.collection('courses').doc(id).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCourse(String id) async {
    await _db.collection('courses').doc(id).delete();

    if (selectedCourseId == id) {
      selectedCourseId = null;
      notifyListeners();
    }

    var records = await _db
        .collection('attendance')
        .where('courseId', isEqualTo: id)
        .get();
    for (var doc in records.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> exportAttendanceExcel(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;

    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];

    sheet.appendRow([
      TextCellValue('Student'),
      TextCellValue('Course'),
      TextCellValue('Status'),
      TextCellValue('Date'),
    ]);

    for (var record in records) {
      final student = students.firstWhere(
        (s) => s.id == record.studentId,
        orElse: () => Student(
          id: record.studentId,
          name: record.studentId,
          phone: '',
          address: '',
          contactId: null,
        ),
      );

      final course = courses.firstWhere(
        (c) => c.id == record.courseId,
        orElse: () => Course(id: record.courseId, name: record.courseId),
      );

      sheet.appendRow([
        TextCellValue(student.name),
        TextCellValue(course.name),
        TextCellValue(record.isPresent ? 'Present' : 'Absent'),
        TextCellValue(record.date.toLocal().toString().split(' ')[0]),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        "${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    await OpenFilex.open(path);
  }
}
