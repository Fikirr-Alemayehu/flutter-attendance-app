import 'package:flutter/material.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:glc/constants/colors.dart';

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
      backgroundColor: kcAppBg,
      appBar: AppBar(
        backgroundColor: kcPrimary,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Row(
              children: [
                // 1. Date
                Expanded(
                  child: _buildFilterChip(
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
                const SizedBox(width: 8),

                // 2. Course
                Expanded(
                  child: _buildFilterChip(
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
                        backgroundColor: kcSurface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Container(
                          color: kcSurface,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ListTile(
                                title: const Text("All Courses", style: TextStyle(fontWeight: FontWeight.bold)),
                                onTap: () => Navigator.pop(context, null),
                              ),
                              const Divider(),
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
                      if (picked != null) {
                        setState(() => selectedCourseId = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kcSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kcOutlineVariant, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          size: 24,
                          color: kcOutline,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: kcFontBold,
                          fontWeight: FontWeight.w500,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text("All", style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Present',
                            child: Text(
                              "Present",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Absent',
                            child: Text(
                              "Absent",
                              style: TextStyle(fontSize: 13),
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
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: kcSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          Icons.people_outline,
                          "Total",
                          "$total",
                          kcPrimary,
                        ),
                        _buildStatCard(
                          Icons.check_circle_outline,
                          "Present",
                          "$present",
                          kcGreen,
                        ),
                        _buildStatCard(
                          Icons.cancel_outlined,
                          "Absent",
                          "$absent",
                          kcRed,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Download Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDownloadButton(
                            icon: Icons.picture_as_pdf,
                            label: "Export PDF",
                            color: kcRed,
                            onTap: () =>
                                vm.exportAttendancePDF(filteredRecords),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDownloadButton(
                            icon: Icons.table_view,
                            label: "Export Excel",
                            color: kcGreen,
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: kcOutline),
                        const SizedBox(height: 16),
                        const Text(
                          "No records found",
                          style: TextStyle(color: kcFont, fontSize: 16),
                        ),
                      ],
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
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: record.isPresent ? kcGreen.withValues(alpha:0.3) : kcOutlineVariant,
                          width: 1,
                        ),
                      ),
                      color: record.isPresent
                          ? kcGreen.withValues(alpha:0.05)
                          : kcSurface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showStudentHistory(context, vm, student),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: record.isPresent
                                        ? [kcGreen, kcGreen.withValues(alpha:0.8)]
                                        : [kcPrimary.withValues(alpha: 0.5), kcPrimary.withValues(alpha: 0.3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    student.name.isNotEmpty ? student.name[0] : "?",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: kcFontBold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: kcFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: record.isPresent
                                      ? kcGreen.withValues(alpha:0.1)
                                      : kcRed.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: record.isPresent
                                        ? kcGreen
                                        : kcRed,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  record.isPresent ? "Present" : "Absent",
                                  style: TextStyle(
                                    color: record.isPresent
                                        ? kcGreen
                                        : kcRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
  Widget _buildFilterChip({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: kcSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kcOutlineVariant, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: kcPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kcFontBold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: kcFont)),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
          decoration: BoxDecoration(
            color: kcSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
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
                    color: kcOutlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kcPrimary, kcPrimaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "History for",
                          style: TextStyle(fontSize: 12, color: kcFont),
                        ),
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kcFontBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              if (history.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: kcOutline),
                      const SizedBox(height: 12),
                      const Text("No records found.", style: TextStyle(color: kcFont)),
                    ],
                  ),
                )
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
                        color: kcSurfaceContainer,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                      fontSize: 16,
                                      color: kcFontBold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kcPrimary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$presentCount/$totalClasses",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kcPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: presentCount / totalClasses,
                                  minHeight: 8,
                                  backgroundColor: kcOutlineVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percentage > 50
                                        ? kcGreen
                                        : kcOrange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$percentage% Attendance",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kcFont,
                                  fontWeight: FontWeight.w500,
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
