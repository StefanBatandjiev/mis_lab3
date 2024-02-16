import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mislab3/register_screen.dart';
import 'authentication_screen.dart';
import 'exam_schedule_screen.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Schedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Initial route when the app starts
      routes: {
        '/': (context) => AuthenticationScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/exam_schedule': (context) =>
            ExamScheduleScreen(), // Define the route for the exam schedule screen
      },
    );
  }
}
