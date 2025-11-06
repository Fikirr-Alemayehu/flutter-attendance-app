import 'package:flutter/material.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class AttendanceHistoryView extends StatefulWidget {
  const AttendanceHistoryView({super.key});

  @override
  State<AttendanceHistoryView> createState() => _AttendanceHistoryViewState();
}

class _AttendanceHistoryViewState extends State<AttendanceHistoryView> {
  DateTime selectedDate = DateTime.now();
  String filter = 'All';
  String? _selectedCourseId;

  List<AttendanceRecord> filteredRecords(List<AttendanceRecord> records) {
    if (filter == 'All') return records;
    if (filter == 'Present') return records.where((r) => r.isPresent).toList();
    if (filter == 'Absent') return records.where((r) => !r.isPresent).toList();
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[100],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[400],
          centerTitle: true,
          title: const Text("History"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 11),
              child: Row(
                children: [
                  DropdownButton<String>(
                    borderRadius: BorderRadius.circular(15),
                    value: filter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                        value: 'Present',
                        child: Text('Present'),
                      ),
                      DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => filter = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.calendar1, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate.toLocal().toString().split(' ')[0],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(LucideIcons.arrowDown, size: 15),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ValueListenableBuilder(
                    valueListenable: vm.courseBox.listenable(),
                    builder: (context, box, _) {
                      return DropdownButton<String?>(
                        // Use String? for the ID
                        value: _selectedCourseId,
                        hint: const Text('All Courses'),
                        items: [
                          // Option for 'All Courses'
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Courses'),
                          ),
                          // Course options from Hive
                          ...box.values.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(course.name),
                            );
                          }),
                        ],
                        onChanged: (id) {
                          setState(() {
                            _selectedCourseId = id;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: vm.attendanceBox.listenable(),
                      builder:
                          (context, Box<AttendanceRecord> attendanceBox, _) {
                            final allRecords = vm.getAttendanceByDate(
                              selectedDate,
                              courseId: _selectedCourseId,
                            );
                            List<AttendanceRecord> records;
                            if (filter == 'All') {
                              records = allRecords;
                            } else if (filter == 'Present') {
                              records = allRecords
                                  .where((r) => r.isPresent)
                                  .toList();
                            } else {
                              records = allRecords
                                  .where((r) => !r.isPresent)
                                  .toList();
                            }
                            int count = records.length;
                            return Text(
                              filter == 'All'
                                  ? 'Total: $count'
                                  : 'Total Count: $count',
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: vm.studentBox.listenable(),
                builder: (context, Box<Student> studentBox, _) {
                  return ValueListenableBuilder(
                    valueListenable: vm.attendanceBox.listenable(),
                    builder: (context, Box<AttendanceRecord> attendanceBox, __) {
                      final List<Student> allStudents = studentBox.values
                          .toList();
                      final List<Map<String, dynamic>> studentAttendanceData =
                          allStudents.map((student) {
                            final record = vm.getSpecificAttendanceRecord(
                              student.id,
                              selectedDate,
                              courseId: _selectedCourseId,
                            );

                            final bool isPresent = record?.isPresent ?? false;
                            final bool hasRecord = record != null;

                            return {
                              'student': student,
                              'isPresent': isPresent,
                              'hasRecord': hasRecord,
                            };
                          }).toList();
                      final List<Map<String, dynamic>> filteredStudents =
                          studentAttendanceData.where((data) {
                            final Student student = data['student'];
                            final bool isPresent = data['isPresent'];

                            if (_selectedCourseId != null) {
                              final hasHistoricalRecordInCourse = vm
                                  .hasHistoricalAttendanceInCourse(
                                    student.id,
                                    _selectedCourseId!,
                                  );
                              if (!hasHistoricalRecordInCourse) {
                                return false;
                              }
                            }
                            if (filter == 'All') {
                              return true;
                            }

                            if (filter == 'Present') {
                              return isPresent;
                            }

                            if (filter == 'Absent') {
                              return !isPresent;
                            }

                            return false;
                          }).toList();

                      if (filteredStudents.isEmpty) {
                        if (_selectedCourseId != null) {
                          return Center(
                            child: Text(
                              "No students relevant to ${vm.courseBox.get(_selectedCourseId)?.name ?? 'this course'} found based on current filters.",
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Center(
                          child: Text(
                            "No students found based on current filters.",
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final data = filteredStudents[index];
                          final Student student = data['student'];
                          final bool isPresent = data['isPresent'];
                          final bool hasRecord = data['hasRecord'];
                          final bool isStudentPresent = hasRecord
                              ? isPresent
                              : false;

                          return Padding(
                            padding: EdgeInsets.all(2),
                            child: Card(
                              color: Colors.grey[200],
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(student.name),
                                subtitle: Text(student.phone),
                                trailing: Text(
                                  isStudentPresent ? "✅ Present" : "❌ Absent",
                                  style: TextStyle(
                                    color: isStudentPresent
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () => _showStudentCourseHistory(
                                  context,
                                  vm,
                                  student,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ValueListenableBuilder(
            valueListenable: vm.attendanceBox.listenable(),
            builder: (context, Box<AttendanceRecord> box, _) {
              final recordsToExport = vm
                  .getAttendanceByDate(
                    selectedDate,
                    courseId: _selectedCourseId,
                  )
                  .where((r) {
                    if (filter == 'All') return true;
                    if (filter == 'Present') return r.isPresent;
                    if (filter == 'Absent') return !r.isPresent;
                    return true;
                  })
                  .toList();
              return Card(
                color: Colors.blueGrey[400],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: recordsToExport.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Choose Export Format'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    final studentBox = vm.studentBox;
                                    await vm.exportToExcel(
                                      recordsToExport,
                                      studentBox,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(LucideIcons.table, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Excel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final studentBox = vm.studentBox;
                                    await vm.exportToPdf(
                                      recordsToExport,
                                      studentBox,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(LucideIcons.fileText, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'PDF',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Download",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.download, size: 15),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showStudentCourseHistory(
    BuildContext context,
    HomeViewModel vm,
    Student student,
  ) {
    final history = vm.getStudentAttendanceHistory(student.id);
    final courseBox = vm.courseBox;

    showModalBottomSheet(
      backgroundColor: Colors.blueGrey[100],
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "History for ${student.name}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                if (history.isEmpty)
                  const Text("No attendance records found for this student.")
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: history.entries.map((entry) {
                        final courseId = entry.key;
                        final records = entry.value;
                        final courseName =
                            courseBox.get(courseId)?.name ?? 'Unknown Course';

                        final presentCount = records
                            .where((r) => r.isPresent)
                            .length;
                        final totalClasses = records.length;

                        return ListTile(
                          title: Text(courseName),
                          subtitle: Text('Total Classes: $totalClasses'),
                          trailing: Text(
                            '$presentCount / $totalClasses Present',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: presentCount > (totalClasses / 2)
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
