import 'package:flutter/material.dart';
import 'package:glc/attendance/models/contact_model.dart';
import 'package:glc/attendance/models/course_model.dart';
import 'package:glc/attendance/models/record.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/view/home.view.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(StudentAdapter()); // register adapter
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(CourseAdapter());

  await Hive.openBox<Student>('students');
  await Hive.openBox<AttendanceRecord>('attendance');
  await Hive.openBox<Contact>('contact');
  await Hive.openBox<Course>('courses');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeView(),
      ),
    );
  }
}
