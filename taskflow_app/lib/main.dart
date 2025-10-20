import 'package:flutter/material.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // A sophisticated teal color
          brightness: Brightness.light,
        ),
        
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        // Define a global style for all Cards.
        // <<< CHANGE: Corrected from CardTheme to CardThemeData
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00897B),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}