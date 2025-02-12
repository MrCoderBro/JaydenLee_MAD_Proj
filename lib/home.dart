
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/aboutpage.dart';
import 'package:project/playlistpage.dart';
import 'package:provider/provider.dart';

import 'exercisepage.dart';
import 'loginpage.dart';
import 'main.dart';
import 'profilepage.dart';
import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

    @override
  void initState() {
    super.initState();
    printAllUsers(); 
  }

  static final List<Widget> _pages = <Widget>[
    ExercisesPage(),
    PlaylistPage(),
    AboutPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    authProvider.logout(userProvider);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Ex-ercise',
          style: GoogleFonts.robotoSlab(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black,),
            onPressed: () {
              _logout();
              
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Playlists',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.green,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}