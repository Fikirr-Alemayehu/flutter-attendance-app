import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/view/edit_stud.view.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/constants/colors.dart';
import 'package:glc/constants/dimention.dart';
import 'package:glc/constants/font_style.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel extends ChangeNotifier {
  late Box<Student> _studentBox;
  late Box<AttendanceRecord> _attendanceBox;
  late Box<Course> courseBox;
  bool isInitialized = false;

  List<Student> _filteredStudents = [];
  Course? _selectedCourse;

  HomeViewModel() {
    _init();
  }

  Future<void> _init() async {
    _studentBox = await Hive.openBox<Student>('students');
    _attendanceBox = await Hive.openBox<AttendanceRecord>('attendance');
    courseBox = await Hive.openBox<Course>('courses');
    isInitialized = true;
    notifyListeners();
  }

  List<Student> get students => _filteredStudents.isNotEmpty
      ? _filteredStudents
      : _studentBox.values.toList();

  Course? get selectedCourse => _selectedCourse;
  Box<Student> get studentBox => _studentBox;
  Box<AttendanceRecord> get attendanceBox => _attendanceBox;

  List<AttendanceRecord> getAttendanceByDate(
    DateTime date, {
    String? courseId,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return _attendanceBox.values
        .where(
          (r) =>
              r.date.year == normalizedDate.year &&
              r.date.month == normalizedDate.month &&
              r.date.day == normalizedDate.day &&
              (courseId == null || r.courseId == courseId),
        )
        .toList();
  }

  Map<String, List<AttendanceRecord>> getStudentAttendanceHistory(
    String studentId,
  ) {
    final studentRecords = _attendanceBox.values
        .where((r) => r.studentId == studentId)
        .toList();

    // Group records by Course ID
    final Map<String, List<AttendanceRecord>> history = {};
    for (var record in studentRecords) {
      if (!history.containsKey(record.courseId)) {
        history[record.courseId] = [];
      }
      history[record.courseId]!.add(record);
    }
    return history;
  }

  // Add a student
  void addStudentWithDetails(
    String name,
    String phone,
    String address,
    String? contactId,
  ) {
    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      address: address,
      contactId: contactId,
    );
    _studentBox.put(newStudent.id, newStudent);
    notifyListeners();
  }

  Future<void> exportToExcel(
    List<AttendanceRecord> records,
    Box<Student> studentBox,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];

    // Add header row
    sheet.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Phone'),
      TextCellValue('Date'),
      TextCellValue("Address"),
      TextCellValue('Status'),
    ]);

    // Add data rows
    for (var record in records) {
      final student = studentBox.get(record.studentId);
      if (student != null) {
        sheet.appendRow([
          TextCellValue(student.name),
          TextCellValue(student.phone),
          TextCellValue(record.date.toLocal().toString().split(' ')[0]),
          TextCellValue(student.address),
          TextCellValue(record.isPresent ? 'Present' : 'Absent'),
        ]);
      }
    }

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.encode()!;
    File(filePath).writeAsBytesSync(fileBytes);

    await OpenFilex.open(filePath);
  }

  Future<void> exportToPdf(
    List<AttendanceRecord> records,
    Box<Student> studentBox,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Attendance Report",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Name', 'Phone', 'Date', 'Address', 'Status'],
                data: records.map((r) {
                  final s = studentBox.get(r.studentId);
                  return [
                    s?.name ?? '',
                    s?.phone ?? '',
                    r.date.toLocal().toString().split(' ')[0],
                    s?.address ?? '',
                    r.isPresent ? 'Present' : 'Absent',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(filePath);
  }

  void setSelectedCourse(Course course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void toggleAttendance(String studentId) {
    if (_selectedCourse == null) {
      return;
    }

    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";
    final recordKey = "${_selectedCourse!.id}-$studentId-$dateKey";

    final existingRecord = attendanceBox.get(recordKey);

    if (existingRecord != null) {
      existingRecord.isPresent = !existingRecord.isPresent;
      existingRecord.save();
    } else {
      // ... create logic using the same recordKey
      attendanceBox.put(
        recordKey,
        AttendanceRecord(
          studentId: studentId,
          courseId: _selectedCourse!.id,
          date: today,
          isPresent: true,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> addCourse(String name) async {
    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    await courseBox.put(course.id, course);
    _selectedCourse = course;
    notifyListeners();
  }

  void showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Course"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Course name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await addCourse(name);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void removeStudent(String id) {
    _studentBox.delete(id);

    // Remove attendance records of this student
    final keysToDelete = _attendanceBox.keys
        .where((key) => key.toString().startsWith(id))
        .toList();
    for (var key in keysToDelete) {
      _attendanceBox.delete(key);
    }

    notifyListeners();
  }

  void editStudent(
    String id,
    String newName,
    String newPhone,
    String newAddress,
  ) {
    final student = _studentBox.get(id);
    if (student == null) return;
    student.name = newName;
    student.phone = newPhone;
    student.address = newAddress;
    student.save();
    notifyListeners();
  }

  // Toggle attendance
  // void toggleAttendance1(String id) {
  //   final student = _students.firstWhere((student) => student.id == id);
  //   student.isPresent = !student.isPresent;
  //   notifyListeners();
  // }

  // Search students
  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = [];
    } else {
      final allStudents = _studentBox.values.toList();
      _filteredStudents = allStudents
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Clear search results
  void clearSearch() {
    _filteredStudents = [];
    notifyListeners();
  }

  void showAddContactDialog(BuildContext context) {
    final vm = Provider.of<ContactViewModel>(context, listen: false);
    final nameController = TextEditingController();
    PhoneNumber number = PhoneNumber(isoCode: 'ET');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: BoxBorder.all(
                    color: const Color.fromARGB(255, 122, 119, 119),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber num) {
                          number = num;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 2,
                        ),
                        initialValue: number,
                        textFieldController: TextEditingController(),
                        inputDecoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Phone',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                        ),
                        formatInput: true,
                        keyboardType: TextInputType.phone,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty || number.phoneNumber == null) return;

              await vm.addContact(name, number.phoneNumber!);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void callPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch dialer for $phoneNumber");
    }
  }

  void showStudentDetails(BuildContext context, Student student) {
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";
    final recordKey = "${_selectedCourse?.id}-${student.id}-$dateKey";
    final currentAttendanceRecord = attendanceBox.get(recordKey);
    final isPresentToday = currentAttendanceRecord?.isPresent ?? false;
    final contactVm = Provider.of<ContactViewModel>(context, listen: false);
    final assignedContact = student.contactId != null
        ? contactVm.getContactById(student.contactId!)
        : null;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                student.name,
                style: kfBodyMedium(
                  context,
                  color: kcWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kdSpaceSmall.height,
              Row(
                children: [
                  Icon(Icons.phone, size: 18, color: kcWhite),
                  kdSpaceTiny.width,
                  Text(
                    student.phone,
                    style: kfBodyMedium(context, color: kcWhite),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.home, size: 18, color: kcWhite),
                  const SizedBox(width: 8),
                  Text(
                    student.address,
                    style: kfBodyMedium(context, color: kcWhite),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: kcWhite),
                  kdSpaceSmall.height,
                  Text(
                    isPresentToday ? "Present" : "Absent",
                    style: kfBodyMedium(
                      context,
                      color: isPresentToday ? kcGreen : kcRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15), // Separator

              if (assignedContact != null) ...[
                Text(
                  "Assigned Follower", // New Heading
                  style: kfBodyMedium(
                    context,
                    color: kcWhite.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: kcWhite),
                    kdSpaceTiny.width,
                    Text(
                      '${assignedContact.name} (${assignedContact.phone})',
                      style: kfBodyMedium(context, color: kcWhite),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Call Student Button (Always available)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        callPhone(student.phone); // Call Student's phone
                      },
                      icon: Icon(Icons.phone_android, color: kcBlueAccent),
                      label: Text(
                        "Call Student",
                        style: kfBodySmall(context, color: kcWhite),
                      ),
                    ),

                    if (assignedContact != null)
                      // Add a separator space
                      const SizedBox(width: 8),

                    // 2. Call Assigned Contact Button (Only if contact exists)
                    if (assignedContact != null)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          callPhone(
                            assignedContact.phone,
                          ); // Call Assigned Contact's phone
                        },
                        icon: Icon(
                          Icons.contact_phone,
                          color: kcWhiteSmoke,
                        ), // Use a different icon/color for visual distinction
                        label: Text(
                          "Call Assigned",
                          style: kfBodySmall(context, color: kcWhite),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditDeleteDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          student.name,
          style: kfBodyLarge(context, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "What would you like to do with this student?",
          style: kfBodySmall(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStudentView(student: student),
                ),
              );
            },
            icon: Icon(Icons.edit, color: kcBlueAccent),
            label: Text(
              "Edit",
              style: kfBodySmall(context, color: kcBlueAccent),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(context, student);
            },
            icon: Icon(Icons.delete, color: kcRed),
            label: Text("Delete", style: kfBodySmall(context, color: kcRed)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Deletion", style: kfBodyLarge(context)),
        content: Text(
          "Are you sure you want to delete ${student.name}?",
          style: kfBodySmall(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: kfBodySmall(context)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kcRed),
            onPressed: () {
              removeStudent(student.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${student.name} deleted")),
              );
            },
            child: Text("Delete", style: kfBodySmall(context)),
          ),
        ],
      ),
    );
  }

  List<Student> getStudentsByCourseId(String? courseId) {
    if (courseId == null) {
      return studentBox.values.toList();
    }
    return studentBox.values
        .where((student) => student.courseId == courseId)
        .toList();
  }
}
