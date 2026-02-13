import 'package:flutter/material.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class AttendanceHistoryView extends StatefulWidget {
  const AttendanceHistoryView({super.key});

  @override
  State<AttendanceHistoryView> createState() => _AttendanceHistoryViewState();
}

class _AttendanceHistoryViewState extends State<AttendanceHistoryView> {
  DateTime selectedDate = DateTime.now();
  String? selectedCourseId;
  String filter = 'All';

  // Search State
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Search student...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                "Attendance History",
                style: TextStyle(color: Colors.white),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                // 1. Date
                Expanded(
                  child: _buildCompactFilter(
                    icon: LucideIcons.calendar,
                    text:
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 6),

                // 2. Course
                Expanded(
                  child: _buildCompactFilter(
                    icon: Icons.book,
                    text: selectedCourseId != null
                        ? vm.courses
                              .firstWhere(
                                (c) => c.id == selectedCourseId,
                                orElse: () => Course(id: '', name: '...'),
                              )
                              .name
                        : "Course",
                    onTap: () async {
                      // Simplified selector for compact view
                      final picked = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => Container(
                          color: Colors.white,
                          child: ListView(
                            padding: const EdgeInsets.all(10),
                            children: [
                              ListTile(
                                title: const Text("select Course"),
                                onTap: () => Navigator.pop(context, null),
                              ),
                              ...vm.courses.map(
                                (c) => ListTile(
                                  title: Text(c.name),
                                  onTap: () => Navigator.pop(context, c.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (picked != null)
                        setState(() => selectedCourseId = picked);
                    },
                  ),
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Container(
                    height: 36, // Compact height
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: Colors.grey,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text("All", style: TextStyle(fontSize: 12)),
                          ),
                          DropdownMenuItem(
                            value: 'Present',
                            child: Text(
                              "Present",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Absent',
                            child: Text(
                              "Absent",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => filter = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          StreamBuilder<List<AttendanceRecord>>(
            stream: vm.attendanceByDate(
              selectedDate,
              courseId: selectedCourseId,
            ),
            builder: (context, snapshot) {
              final rawRecords = snapshot.data ?? [];

              final recordMap = {for (var r in rawRecords) r.studentId: r};

              final records = vm.students.map((student) {
                return recordMap[student.id] ??
                    AttendanceRecord(
                      studentId: student.id,
                      courseId: selectedCourseId ?? '',
                      date: selectedDate,
                      isPresent: false,
                    );
              }).toList();

              final filteredRecords = records.where((record) {
                if (filter == 'Present' && !record.isPresent) return false;
                if (filter == 'Absent' && record.isPresent) return false;

                if (_searchQuery.isNotEmpty) {
                  final student = vm.students.firstWhere(
                    (s) => s.id == record.studentId,
                    orElse: () => Student(
                      id: record.studentId,
                      name: 'Unknown',
                      phone: '',
                      address: '',
                    ),
                  );
                  return student.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }
                return true;
              }).toList();

              final total = filteredRecords.length;
              final present = filteredRecords.where((r) => r.isPresent).length;
              final absent = total - present;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCompactStat(
                          Icons.people_outline,
                          "Total",
                          "$total",
                          Colors.blueGrey,
                        ),
                        _buildCompactStat(
                          Icons.check_circle_outline,
                          "Present",
                          "$present",
                          Colors.green,
                        ),
                        _buildCompactStat(
                          Icons.cancel_outlined,
                          "Absent",
                          "$absent",
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Download Buttons (Compact)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDownloadButton(
                            icon: Icons.picture_as_pdf,
                            label: "PDF",
                            color: Colors.redAccent,
                            onTap: () =>
                                vm.exportAttendancePDF(filteredRecords),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDownloadButton(
                            icon: Icons.table_view,
                            label: "Excel",
                            color: Colors.green,
                            onTap: () =>
                                vm.exportAttendanceExcel(filteredRecords),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // ---------------- LIST VIEW ----------------
          Expanded(
            child: StreamBuilder<List<AttendanceRecord>>(
              stream: vm.attendanceByDate(
                selectedDate,
                courseId: selectedCourseId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawRecords = snapshot.data ?? [];

                // Map existing records
                final recordMap = {for (var r in rawRecords) r.studentId: r};

                // Create FULL list (all students)
                final records = vm.students.map((student) {
                  return recordMap[student.id] ??
                      AttendanceRecord(
                        studentId: student.id,
                        courseId: selectedCourseId ?? '',
                        date: selectedDate,
                        isPresent: false,
                      );
                }).toList();

                // Apply filters
                final filteredRecords = records.where((record) {
                  if (filter == 'Present' && !record.isPresent) return false;
                  if (filter == 'Absent' && record.isPresent) return false;

                  if (_searchQuery.isNotEmpty) {
                    final student = vm.students.firstWhere(
                      (s) => s.id == record.studentId,
                      orElse: () => Student(
                        id: record.studentId,
                        name: 'Unknown',
                        phone: '',
                        address: '',
                      ),
                    );

                    return student.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                  }

                  return true;
                }).toList();

                if (filteredRecords.isEmpty) {
                  return const Center(
                    child: Text(
                      "No records found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];

                    final student = vm.students.firstWhere(
                      (s) => s.id == record.studentId,
                      orElse: () => Student(
                        id: record.studentId,
                        name: record.studentId,
                        phone: '',
                        address: '',
                      ),
                    );

                    final course = vm.courses.firstWhere(
                      (c) => c.id == record.courseId,
                      orElse: () =>
                          Course(id: record.courseId, name: record.courseId),
                    );

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey.shade100,
                          child: Text(
                            student.name.isNotEmpty ? student.name[0] : "?",
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: record.isPresent
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: record.isPresent
                                  ? Colors.green
                                  : Colors.red,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            record.isPresent ? "Present" : "Absent",
                            style: TextStyle(
                              color: record.isPresent
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        onTap: () => _showStudentHistory(context, vm, student),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper for compact top filters
  Widget _buildCompactFilter({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDownloadButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentHistory(
    BuildContext context,
    HomeViewModel vm,
    Student student,
  ) async {
    final history = await vm.getStudentAttendanceHistory(
      student.id,
      courseId: selectedCourseId,
    );
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueGrey[100],
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : "?",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "History for",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              if (history.isEmpty)
                const Center(child: Text("No records found."))
              else
                Expanded(
                  child: ListView(
                    children: history.entries.map((entry) {
                      final courseId = entry.key;
                      final records = entry.value;

                      final courseName = vm.courses
                          .firstWhere(
                            (c) => c.id == courseId,
                            orElse: () => Course(id: courseId, name: courseId),
                          )
                          .name;

                      final presentCount = records
                          .where((r) => r.isPresent)
                          .length;
                      final totalClasses = records.length;
                      final percentage = (presentCount / totalClasses * 100)
                          .toInt();

                      return Card(
                        elevation: 0,
                        color: Colors.blueGrey[50],
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    courseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "$presentCount/$totalClasses",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: presentCount / totalClasses,
                                  minHeight: 6,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percentage > 50
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$percentage% Attendance",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
