import 'package:app/pages/home_page.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: .light,
      home: HomePage(),
    );
  }
}
