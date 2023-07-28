import 'package:flutter/material.dart';
import 'package:toolbox/countries/countries.dart';
import 'package:toolbox/currency_converter.dart';
import 'package:toolbox/home_page.dart';
import 'package:toolbox/phone_number.dart';
import 'package:toolbox/weather/weather_screen.dart';

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
      title: 'Pays',
      page: const CountriesPage(),
    ),
    ListTileData(
      title: 'Convertisseur de devises',
      page: const CurrencyConverterPage(),
    ),
    ListTileData(
      title: 'Météo',
      page: const WeatherScreen(),
    ),
    ListTileData(
      title: 'Information sur un numéro de téléphone',
      page: const PhoneValidationScreen(),
    ),
    // Add more ListTiles here if needed
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
