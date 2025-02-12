import 'package:flutter/material.dart';
import 'package:project/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'home.dart';
import 'loginpage.dart';
import 'provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.deleteDatabase(); // Deletes the existing database first
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// For Debugging
Future<void> printAllUsers() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = await dbHelper.getAllUsers();
  print("All Users:");
  for (var user in users) {
    print(user);
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return auth.isAuthenticated ? HomePage() : LoginPage();
        },
      ),
    );
  }
}