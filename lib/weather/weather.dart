class WeatherData {
  final String locationName;
  final String country;
  final double temperatureCelsius;
  final String conditionText;
  final String conditionIcon;

  WeatherData({
    required this.locationName,
    required this.country,
    required this.temperatureCelsius,
    required this.conditionText,
    required this.conditionIcon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    final currentData = json['current'];

    return WeatherData(
      locationName: locationData['name'],
      country: locationData['country'],
      temperatureCelsius: currentData['temp_c'],
      conditionText: currentData['condition']['text'],
        conditionIcon: 'https:${currentData['condition']['icon']}',
    );
  }
}