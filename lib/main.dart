import 'package:flutter/material.dart';
import 'package:toolbox/EuroMillionDraw.dart';
import 'package:toolbox/countries/countries.dart';
import 'package:toolbox/currency_converter.dart';
import 'package:toolbox/home_page.dart';
import 'package:toolbox/profiles/profile_screen.dart';
import 'package:toolbox/qr_code.dart';
import 'package:toolbox/weather_screen.dart';

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
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String _currentPageTitle = 'Accueil'; // Initialize with "Accueil"
  Widget _currentBody = const HomePage(); // Initialize with HomePage()

  // Define a list containing ListTileData for each item in the drawer
  final List<ListTileData> _listTileData = [
    ListTileData(
      title: 'Accueil',
      page: const HomePage(),
    ),
    ListTileData(
      title: 'Météo',
      page: const WeatherScreen(),
    ),
    ListTileData(
      title: 'Code QR',
      page: const QRCodeGeneratorApp(),
    ),
    ListTileData(
      title: 'Euro Million',
      page: const EuroMillionScreen(),
    ),
    ListTileData(
      title: 'Liste des pays',
      page: const CountriesPage(),
    ),
    ListTileData(
      title: 'Génération de profil',
      page: const ProfileScreen(),
    ),
    ListTileData(
      title: 'Convertisseur de devises',
      page: const CurrencyConverterPage(),
    ),
  ];

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
                // backgroundImage: AssetImage('assets/profile_picture.png'),
              ),
            ),
            // Create ListTiles dynamically using the _listTileData
            ..._listTileData.map((data) {
              return ListTile(
                title: Text(data.title),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentPageTitle = data.title; // Update the title using the selected ListTile title
                    _currentBody = data.page; // Update the body using the associated page of the selected ListTile
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Create a class to represent the information of each ListTile
class ListTileData {
  final String title;
  final Widget page;

  ListTileData({required this.title, required this.page});
}
