import 'package:flutter/material.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/view/add_student.view.dart';
import 'package:glc/attendance/view/contact.view.dart';
import 'package:glc/attendance/view/view_attendance.view.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewtate();
}

class _HomeViewtate extends State<HomeView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);
    if (!vm.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[100],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[400],
          title: Container(
            margin: EdgeInsets.all(5),
            child: !_isSearching
                ? Text('Attendance App')
                : TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                    ),
                    onChanged: (query) => vm.searchStudents(query),
                  ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    vm.clearSearch();
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'View Attendance History',
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const AttendanceHistoryView(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                });
              },
            ),
          ],
        ),

        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: vm.courseBox.listenable(),
                          builder: (context, Box<Course> box, _) {
                            return DropdownButton<Course>(
                              borderRadius: BorderRadius.circular(25),
                              value: vm.selectedCourse,
                              hint: const Text('Select Course'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: box.values.map((course) {
                                return DropdownMenuItem<Course>(
                                  value: course,
                                  child: Text(course.name),
                                );
                              }).toList(),
                              onChanged: (course) {
                                if (course != null)
                                  print("Selected course: ${course.name}");
                                vm.setSelectedCourse(course!);
                              },
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.blueGrey),
                        tooltip: "Add Course",
                        onPressed: () => vm.showAddCourseDialog(context),
                      ),
                    ],
                  ),
                ),

                // then your ListView:
                Expanded(
                  child: ValueListenableBuilder<Box<AttendanceRecord>>(
                    valueListenable: vm.attendanceBox.listenable(),
                    builder: (context, box, _) {
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: vm.students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final student = vm.students[index];
                          final today = DateTime.now();
                          final dateKey =
                              "${today.year}-${today.month}-${today.day}";
                          final recordKey =
                              "${vm.selectedCourse?.id}-${student.id}-$dateKey";

                          final record = box.get(recordKey);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Checkbox(
                                value: record?.isPresent ?? false,
                                onChanged: (_) {
                                  if (vm.selectedCourse != null) {
                                    vm.toggleAttendance(student.id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a course first',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              onTap: () =>
                                  vm.showStudentDetails(context, student),
                              onLongPress: () =>
                                  vm.showEditDeleteDialog(context, student),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.blueGrey[400],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddStudentView()),
                  );
                },
                child: const Icon(Icons.person_add_alt_1),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.blueGrey[400],
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ContactView(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: const Icon(LucideIcons.phoneCall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
