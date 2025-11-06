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

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context, listen: false);

    List<AttendanceRecord> filteredRecords(List<AttendanceRecord> records) {
      if (filter == 'All') return records;
      if (filter == 'Present')
        return records.where((r) => r.isPresent).toList();
      if (filter == 'Absent')
        return records.where((r) => !r.isPresent).toList();
      return records;
    }

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

        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date picker
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2023),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
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
                              (
                                context,
                                Box<AttendanceRecord> attendanceBox,
                                _,
                              ) {
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
                      // Count text
                    ],
                  ),
                ),

                // Attendance list
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: vm.attendanceBox.listenable(),
                    builder: (context, Box<AttendanceRecord> attendanceBox, _) {
                      final allRecords = vm.getAttendanceByDate(
                        selectedDate,
                        courseId: _selectedCourseId,
                      );
                      List<AttendanceRecord> records;
                      if (filter == 'All') {
                        records = allRecords;
                      } else if (filter == 'Present') {
                        records = allRecords.where((r) => r.isPresent).toList();
                      } else {
                        records = allRecords
                            .where((r) => !r.isPresent)
                            .toList();
                      }

                      if (records.isEmpty) {
                        return const Center(
                          child: Text("No attendance recorded for this date."),
                        );
                      }

                      return ValueListenableBuilder(
                        valueListenable: vm.studentBox.listenable(),
                        builder: (context, Box<Student> studentBox, _) {
                          return ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              final student = studentBox.get(record.studentId);
                              if (student == null) return const SizedBox();
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
                                      record.isPresent
                                          ? "✅ Present"
                                          : "❌ Absent",
                                      style: TextStyle(
                                        color: record.isPresent
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

            // Export button at bottom-right
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Card(
            color: Colors.blueGrey[400],
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Choose Export Format'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final records = filteredRecords(
                            vm.getAttendanceByDate(selectedDate),
                          );
                          final studentBox = vm.studentBox;
                          await vm.exportToExcel(records, studentBox);
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: const [
                            Icon(LucideIcons.table, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Excel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final records = filteredRecords(
                            vm.getAttendanceByDate(selectedDate),
                          );
                          final studentBox = vm.studentBox;
                          await vm.exportToPdf(records, studentBox);
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: const [
                            Icon(LucideIcons.fileText, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'PDF',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }

  // In _AttendanceHistoryViewState:

  void _showStudentCourseHistory(
    BuildContext context,
    HomeViewModel vm,
    Student student,
  ) {
    final history = vm.getStudentAttendanceHistory(student.id);
    final courseBox = vm.courseBox;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
                Expanded(
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
        );
      },
    );
  }
}
