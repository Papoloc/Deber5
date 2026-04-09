import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherData? _weatherData;
  List<String> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const String _favoritesKey = 'favorite_cities';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList(_favoritesKey) ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites);
  }

  Future<void> _consultarClima() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null;
    });

    try {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _guardarEnFavoritos() {
    if (_weatherData == null) return;
    final city = _weatherData!.city.toLowerCase();
    if (!_favorites.contains(city)) {
      setState(() {
        _favorites.add(city);
      });
      _saveFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$city guardada en favoritos')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La ciudad ya está en favoritos')),
      );
    }
  }

  void _eliminarFavorito(String city) {
    setState(() {
      _favorites.remove(city);
    });
    _saveFavorites();
  }

  Future<void> _consultarFavorito(String city) async {
    _cityController.text = city;
    await _consultarClima();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App de Clima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ingresa la Ciudad',
              ),
              onSubmitted: (_) => _consultarClima(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _consultarClima,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Consultar Clima'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            if (_weatherData != null) ...[
              _buildWeatherCard(_weatherData!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _guardarEnFavoritos,
                child: const Text('Guardar en Favoritos'),
              ),
            ],
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  'Ciudades Favoritas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _favorites.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay ciudades favoritas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final city = _favorites[index];
                        return Card(
                          child: ListTile(
                            title: Text(city),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarFavorito(city),
                            ),
                            onTap: () => _consultarFavorito(city),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${data.icon}@2x.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.cloud, size: 50),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ciudad: ${data.city}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Temperatura: ${data.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
