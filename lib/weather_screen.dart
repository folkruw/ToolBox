import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  String currentTime = '12:00';
  String currentDate = 'Dimanche 6 Août 2023';
  double temperature = 0.0;
  int weatherIconId = 0;
  IconData weatherIcon = Icons.wb_sunny;

  List<String> hours = [];
  List<double> temperatures = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 50.0),
          Text(
            currentDate,
            style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherIcon(weatherIcon, Colors.yellow),
              const SizedBox(width: 20.0),
              Text(
                '$temperature °C',
                style: const TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                updateTime(index);
              },
              itemBuilder: (context, index) {
                String time = currentTime;
                return GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(index);
                  },
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(IconData iconData, Color color) {
    return Icon(
      iconData,
      color: color,
      size: 60.0,
    );
  }


  Future<void> fetchWeatherData() async {
    const apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=50.4541&longitude=3.9523&hourly=temperature_2m,weathercode';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hourlyData = data['hourly'];

      List<String> fetchedHours = List<String>.from(hourlyData['time']);
      List<double> fetchedTemperatures =
      List<double>.from(hourlyData['temperature_2m']);

      final now = DateTime.now();
      final currentDateFormatted = DateFormat('yyyy-MM-dd').format(now);
      final currentTimeFormatted = DateFormat('HH:mm').format(now);

      int index = -1;
      for (int i = 0; i < fetchedHours.length; i++) {
        if (fetchedHours[i].startsWith(currentDateFormatted)) {
          final timeFromAPI = fetchedHours[i].substring(11, 16); // Extracts 'HH:mm' from 'yyyy-MM-ddTHH:mm:ss' format
          if (timeFromAPI.compareTo(currentTimeFormatted) <= 0) {
            index = i;
          } else {
            break;
          }
        }
      }

      if (index == -1) {
        index = 0;
      }

      setState(() {
        hours = fetchedHours;
        temperatures = fetchedTemperatures;
        updateTime(index);
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }


  IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.cloud_queue;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 56:
      case 57:
        return Icons.ac_unit;
      case 61:
      case 63:
      case 65:
        return Icons.opacity;
      case 66:
      case 67:
        return Icons.ac_unit_outlined;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit_rounded;
      case 77:
        return Icons.grain_outlined;
      case 80:
      case 81:
      case 82:
        return Icons.show_chart;
      case 85:
      case 86:
        return Icons.ac_unit_sharp;
      case 95:
        return Icons.flash_on;
      case 96:
      case 99:
        return Icons.flash_on_outlined;
      default:
        return Icons.error_outline; // Icône par défaut pour un code météo inconnu
    }
  }

  void updateTime(int index) async {
    setState(() {
      final time = TimeOfDay.fromDateTime(DateTime.parse(hours[index]));

      final date = DateTime.parse(hours[index]);
      final dayOfWeek = DateFormat('EEEE').format(date);
      final dayOfMonth = date.day;
      final month = DateFormat('MMMM').format(date);
      final year = date.year;

      currentDate = '$dayOfWeek $dayOfMonth $month $year';
      currentTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    });

    final newTemperatureAndWeatherCode =
    await fetchTemperatureAndWeatherCode(index);

    setState(() {
      temperature = newTemperatureAndWeatherCode['temperature'];
      weatherIcon = getWeatherIcon(newTemperatureAndWeatherCode['weatherCode']);
      weatherIconId = newTemperatureAndWeatherCode['weatherCode'];
    });
  }

  Future<Map<String, dynamic>> fetchTemperatureAndWeatherCode(
      int index) async {
    if (index >= 0 && index < temperatures.length) {
      return {'temperature': temperatures[index], 'weatherCode': -1};
    } else {
      return {'temperature': 0.0, 'weatherCode': -1};
    }
  }
}
