import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final String icon;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class WeatherService {
  static const String _apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> fetchWeather(String city) async {
    final uri = Uri.parse(
      '$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=es',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Ciudad no encontrada');
    } else {
      throw Exception('Error al consultar el clima (${response.statusCode})');
    }
  }
}
