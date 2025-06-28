import 'package:flutter/material.dart';
import 'package:setjws/homepagecontent.dart';
import 'package:setjws/jwspage.dart';
import 'package:setjws/ledpage.dart';
import 'package:setjws/murottalpage.dart';
import 'package:setjws/timepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JWS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.amber,
          surface: Colors.white,
        ),
        // Perbaikan di sini: Ganti CardTheme menjadi CardThemeData
        cardTheme: CardThemeData( // <--- PERBAIKAN DI SINI
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.blue.shade800),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  // List of tabs/screens for the BottomNavigationBar
  final List<Widget> _tabs = [
    JwsScreen(),
    LedScreen(), // Replaced Center(child: Text("LED Page")) with LedScreen()
    HomePageContent(),
    MurottalScreen(),
    TimeScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajun JWS Setting'),
        centerTitle: true, // Center the app bar title
        elevation: 4, // Add some shadow to the app bar
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Ensure labels are always visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'JWS'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'LED'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Murottal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'DateTime',
          ),
        ],
      ),
    );
  }
}
