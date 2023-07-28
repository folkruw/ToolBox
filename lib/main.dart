import 'package:flutter/material.dart';
import 'package:toolbox/countries/countries.dart';
import 'package:toolbox/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentPageTitle = 'Accueil'; // Initialize with "Accueil"
  Widget _currentBody = const HomePage(); // Initialize with CountriesPage()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageTitle), // Use the dynamic title
      ),
      body: _currentBody,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Nicolas'),
              accountEmail: Text('nicolas@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_picture.png'),
              ),
            ),
            ListTile(
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentPageTitle = 'Accueil'; // Update title to "Accueil"
                  _currentBody = const HomePage();
                });
              },
            ),
            ListTile(
              title: const Text('Pays'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentPageTitle = 'Pays'; // Update title to "Pays"
                  _currentBody = const CountriesPage();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
