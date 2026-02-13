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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blueGrey,

          // toolbarHeight: 80,
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
                      child: ChoiceChip(
                        label: Text(course.name ?? 'Unknown Course'),
                        selected: isSelected,
                        onSelected: (_) {
                          if (vm.selectedCourseId == course.id) {
                            vm.setSelectedCourse(null);
                          } else {
                            vm.setSelectedCourse(course.id);
                          }
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.blueGrey[100],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.blueGrey[900]
                              : Colors.blueGrey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blueGrey
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? "No students added yet."
                            : "No students found.",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
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
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isPresent
                                  ? Colors.green.shade50
                                  : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: isPresent
                                      ? Colors.green
                                      : Colors.blueGrey,
                                  child: Text(
                                    (student.name ?? '?').isNotEmpty
                                        ? (student.name ?? '?')[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.name ?? 'Unknown Student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Switch(
                                  value: isPresent,
                                  activeThumbColor: Colors.green,
                                  onChanged: (value) {
                                    if (vm.selectedCourseId == null) {
                                      DelightToastBar(
                                        autoDismiss: true,
                                        builder: (context) => const ToastCard(
                                          leading: Icon(
                                            Icons.flutter_dash,
                                            size: 28,
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
                                onTap: () => _showStudentDetails(
                                  context,
                                  student,
                                  isPresent,
                                ),
                                onLongPress: () =>
                                    _showEditDeleteDialog(context, vm, student),
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
                color: Colors.orange,
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
                color: Colors.blue,
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
                color: Colors.green,
                onTap: () {
                  setState(() => _isFabMenuOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddStudentView()),
                  );
                },
              ),
              const SizedBox(height: 15),
            ],
            FloatingActionButton(
              onPressed: () {
                setState(() => _isFabMenuOpen = !_isFabMenuOpen);
              },
              backgroundColor: Colors.blueGrey,
              child: Icon(
                _isFabMenuOpen ? Icons.close : Icons.menu,
                color: Colors.white,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: label,
            mini: true,
            onPressed: onTap,
            backgroundColor: color,
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
      builder: (_) {
        return Consumer<ContactViewModel>(
          builder: (context, contactVm, child) {
            final follower = student.contactId != null
                ? contactVm.getContactById(student.contactId!)
                : null;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueGrey[100],
                    child: Text(
                      (student.name ?? '?').isNotEmpty
                          ? (student.name ?? '?')[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    student.name ?? 'Unknown Student',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isPresent ? "Present" : "Absent",
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(Icons.phone, student.phone ?? 'No Phone', () {
                    if (student.phone.isNotEmpty) {
                      contactVm.launchDialer(student.phone);
                    }
                  }),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    Icons.home,
                    student.address ?? 'No Address',
                    null,
                  ),
                  if (follower != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.person,
                      "Follower: ${follower.name}",
                      () {
                        contactVm.launchDialer(follower.phone);
                      },
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 15),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            if (onTap != null)
              const Icon(Icons.call, color: Colors.green, size: 20),
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
      if (confirm == true) vm.deleteStudent(student.id);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(course == null ? 'Add Course' : 'Edit Course'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Course Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (course == null) {
                  await vm.addCourse(name);
                } else {
                  await vm.updateCourse(course.id, name);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }

  void _showManageCoursesSheet(BuildContext context, HomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manage Courses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, child) {
                  return vm.courses.isEmpty
                      ? const Center(child: Text("No courses found."))
                      : ListView.builder(
                          itemCount: vm.courses.length,
                          itemBuilder: (context, index) {
                            final course = vm.courses[index];
                            final isSelected = course.id == vm.selectedCourseId;

                            return Card(
                              elevation: 1,
                              color: isSelected
                                  ? Colors.blueGrey[50]
                                  : Colors.white,
                              child: ListTile(
                                title: Text(
                                  course.name ?? 'Unknown Course',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blueGrey
                                        : Colors.black,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        _showCourseDialog(
                                          context,
                                          vm,
                                          course: course,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
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
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await vm.deleteCourse(course.id);
                                          if (context.mounted)
                                            Navigator.pop(context);
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add New Course",
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
