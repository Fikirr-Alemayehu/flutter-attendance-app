import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/view/add_student.view.dart';
import 'package:glc/attendance/view/contact.view.dart';
import 'package:glc/attendance/view/edit_stud.view.dart';
import 'package:glc/attendance/view/view_attendance.view.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:provider/provider.dart';
import 'package:glc/constants/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isFabMenuOpen = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);

    if (vm.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredStudents = vm.students.where((student) {
      final nameLower = (student.name ?? '').toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: kcAppBg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kcPrimary,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Search students...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Attendance App",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${DateTime.now().day} ${_getMonth(DateTime.now().month)} ${DateTime.now().year}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

          actions: [
            if (!_isSearching)
              IconButton(
                icon: const Icon(Icons.menu_book, color: Colors.white70),
                onPressed: () => _showManageCoursesSheet(context, vm),
                tooltip: "Manage Courses",
              ),
            if (!_isSearching)
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                tooltip: "Search",
              ),
          ],
        ),

        body: Column(
          children: [
            if (vm.courses.isNotEmpty)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: vm.courses.length,
                  itemBuilder: (context, index) {
                    final course = vm.courses[index];
                    final isSelected = course.id == vm.selectedCourseId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(course.name ?? 'Unknown Course'),
                        selected: isSelected,
                        onSelected: (_) {
                          if (vm.selectedCourseId == course.id) {
                            vm.setSelectedCourse(null);
                          } else {
                            vm.setSelectedCourse(course.id);
                          }
                        },
                        selectedColor: kcPrimary,
                        backgroundColor: kcSurface,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : kcFont,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? kcPrimary : kcOutlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    );
                  },
                ),
              ),

            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: kcOutline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? "No students added yet."
                                : "No students found.",
                            style: TextStyle(color: kcFont, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];

                        return StreamBuilder(
                          stream: vm.attendanceForStudent(student.id),
                          builder: (context, snapshot) {
                            final record = snapshot.data;
                            final isPresent = record?.isPresent ?? false;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isPresent ? kcGreen.withValues(alpha:0.3) : kcOutlineVariant,
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isPresent
                                  ? kcGreen.withValues(alpha:0.08)
                                  : kcSurface,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showStudentDetails(
                                  context,
                                  student,
                                  isPresent,
                                ),
                                onLongPress: () =>
                                    _showEditDeleteDialog(context, vm, student),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isPresent
                                                ? [kcGreen, kcGreen.withValues(alpha:0.8)]
                                                : [kcPrimary, kcPrimaryLight],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isPresent ? kcGreen : kcPrimary).withValues(alpha:0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            (student.name ?? '?').isNotEmpty
                                                ? (student.name ?? '?')[0].toUpperCase()
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
                                              student.name ?? 'Unknown Student',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: kcFontBold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              student.phone ?? 'No phone',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: kcFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: isPresent,
                                        activeTrackColor: kcGreen,
                                        onChanged: (value) {
                                          if (vm.selectedCourseId == null) {
                                            DelightToastBar(
                                              autoDismiss: true,
                                              builder: (context) => const ToastCard(
                                                leading: Icon(
                                                  Icons.warning_rounded,
                                                  size: 28,
                                                  color: Colors.orange,
                                                ),
                                                title: Text(
                                                  "Please select a course first!",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ).show(context);

                                            return;
                                          }

                                          vm.toggleAttendance(student.id);
                                        },
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

        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isFabMenuOpen) ...[
              _buildFabItem(
                icon: Icons.history,
                label: "Report",
                color: kcOrange,
                onTap: () {
                  setState(() => _isFabMenuOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildFabItem(
                icon: Icons.group,
                label: "Follow Up",
                color: kcSecondary,
                onTap: () {
                  setState(() => _isFabMenuOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactView()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildFabItem(
                icon: Icons.person_add,
                label: "Add Student",
                color: kcGreen,
                onTap: () {
                  setState(() => _isFabMenuOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddStudentView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
            ],
            FloatingActionButton.extended(
              onPressed: () {
                setState(() => _isFabMenuOpen = !_isFabMenuOpen);
              },
              backgroundColor: kcPrimary,
              elevation: 4,
              icon: Icon(
                _isFabMenuOpen ? Icons.close : Icons.add,
                color: Colors.white,
              ),
              label: Text(
                _isFabMenuOpen ? "Close" : "Actions",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kcSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 8),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: kcFontBold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: label,
            mini: true,
            onPressed: onTap,
            backgroundColor: color,
            elevation: 3,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(
    BuildContext context,
    Student student,
    bool isPresent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Consumer<ContactViewModel>(
          builder: (context, contactVm, child) {
            final follower = student.contactId != null
                ? contactVm.getContactById(student.contactId!)
                : null;

            return Container(
              decoration: BoxDecoration(
                color: kcSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: kcOutlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPresent
                            ? [kcGreen, kcGreen.withValues(alpha:0.8)]
                            : [kcPrimary, kcPrimaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isPresent ? kcGreen : kcPrimary).withValues(alpha:0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        (student.name ?? '?').isNotEmpty
                            ? (student.name ?? '?')[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name ?? 'Unknown Student',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kcFontBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPresent ? kcGreen.withValues(alpha:0.1) : kcRed.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPresent ? kcGreen : kcRed,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isPresent ? "Present" : "Absent",
                      style: TextStyle(
                        color: isPresent ? kcGreen : kcRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.phone, student.phone ?? 'No Phone', () {
                    if (student.phone.isNotEmpty) {
                      contactVm.launchDialer(student.phone);
                    }
                  }),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.home,
                    student.address ?? 'No Address',
                    null,
                  ),
                  if (follower != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.person,
                      "Follower: ${follower.name}",
                      () {
                        contactVm.launchDialer(follower.phone);
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kcSurfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kcPrimary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: kcPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: kcFontBold))),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.call, color: kcGreen, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDeleteDialog(
    BuildContext context,
    HomeViewModel vm,
    Student student,
  ) async {
    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(student.name ?? 'Student'),
        content: const Text("Manage student?"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.edit, color: Colors.blue),
            label: const Text("Edit"),
            onPressed: () => Navigator.pop(context, "edit"),
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text("Delete"),
            onPressed: () => Navigator.pop(context, "delete"),
          ),
        ],
      ),
    );

    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditStudentView(student: student)),
      );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Delete ${student.name ?? 'this student'}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        vm.deleteStudent(student.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text("${student.name ?? 'Student'} deleted"),
              ],
            ),
            backgroundColor: kcRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showCourseDialog(
    BuildContext context,
    HomeViewModel vm, {
    Course? course,
  }) {
    final controller = TextEditingController(text: course?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          course == null ? 'Add Course' : 'Edit Course',
          style: const TextStyle(fontWeight: FontWeight.bold, color: kcFontBold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Course Name',
            filled: true,
            fillColor: kcSurfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kcOutlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kcPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kcFont)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (course == null) {
                  await vm.addCourse(name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            const Text("Course added successfully!"),
                          ],
                        ),
                        backgroundColor: kcGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  await vm.updateCourse(course.id, name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            const Text("Course updated successfully!"),
                          ],
                        ),
                        backgroundColor: kcGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showManageCoursesSheet(BuildContext context, HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kcSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manage Courses",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kcFontBold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: kcFont,
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, child) {
                  return vm.courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_outlined, size: 48, color: kcOutline),
                              const SizedBox(height: 12),
                              const Text("No courses found.", style: TextStyle(color: kcFont)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: vm.courses.length,
                          itemBuilder: (context, index) {
                            final course = vm.courses[index];
                            final isSelected = course.id == vm.selectedCourseId;

                            return Card(
                              elevation: 0,
                              color: isSelected ? kcPrimary.withValues(alpha:0.08) : kcSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? kcPrimary : kcOutlineVariant,
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(
                                  course.name ?? 'Unknown Course',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? kcPrimary : kcFontBold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      onPressed: () {
                                        _showCourseDialog(
                                          context,
                                          vm,
                                          course: course,
                                        );
                                      },
                                      color: kcPrimary,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: kcRed,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            title: const Text("Delete Course"),
                                            content: Text(
                                              "Delete ${course.name ?? 'this course'}?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: kcRed,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await vm.deleteCourse(course.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(Icons.delete_outline, color: Colors.white),
                                                    const SizedBox(width: 12),
                                                    Text("${course.name ?? 'Course'} deleted"),
                                                  ],
                                                ),
                                                backgroundColor: kcRed,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  vm.setSelectedCourse(course.id);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add New Course",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  _showCourseDialog(context, vm);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
