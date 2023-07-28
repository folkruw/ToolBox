import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/weather/weather.dart';
import 'package:toolbox/weather/weather_api.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final apiClient = WeatherApiClient();

    try {
      final weatherData = await apiClient.fetchWeatherData();
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      // Handle error (e.g., display an error message)
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _weatherData != null
          ? _buildWeatherContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWeatherContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_weatherData!.locationName}, ${_weatherData!.country}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${_weatherData!.temperatureCelsius}°C',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            Image.network(_weatherData!.conditionIcon),
            const SizedBox(height: 20),
            Text(
              _weatherData!.conditionText,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
