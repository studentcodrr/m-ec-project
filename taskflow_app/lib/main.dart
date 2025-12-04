import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart'; 

import 'models/task_model.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Hive (Offline Database)
  await Hive.initFlutter();
  
  // 3. Register the Adapter so Hive understands your TaskModel
  Hive.registerAdapter(TaskModelAdapter());
  
  // 4. Open the box where tasks are stored
  await Hive.openBox<TaskModel>('tasks');
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      
      // CRITICAL: Use AuthGate instead of 'initialRoute: /login'
      // This allows the app to bypass login if the user is cached (even offline)
      home: const AuthGate(), 
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(), 
      },
    );
  }
}

/// A wrapper widget that decides where to go based on Auth State
/// This works OFFLINE because Firebase Auth caches the user token locally.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // This stream emits the User instantly if cached
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, the user is logged in (or cached)
        if (snapshot.hasData) {
          return const HomePage();
        }
        
        // Otherwise, they need to log in
        return const LoginPage();
      },
    );
  }
}