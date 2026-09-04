import 'package:app/pages/main_layout.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  Intl.defaultLocale = 'pt_BR';

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
      home: MainLayout(),
    );
  }
}
