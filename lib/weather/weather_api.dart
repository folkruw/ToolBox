import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toolbox/api_key.dart';
import 'package:toolbox/weather/weather.dart';

class WeatherApiClient {
  static const String baseUrl =
      'https://weatherapi-com.p.rapidapi.com/current.json?q=50.454972%2C%203.952667';

  static const Map<String, String> headers = {
    'X-RapidAPI-Key': APIKey.weatherAPIKey,
    'X-RapidAPI-Host': 'weatherapi-com.p.rapidapi.com',
  };

  Future<WeatherData> fetchWeatherData() async {
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
