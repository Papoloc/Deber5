# Deber 5 - App de Clima

Aplicación Flutter que consulta el clima de cualquier ciudad usando la API de OpenWeatherMap y permite guardar ciudades favoritas con SharedPreferences.

## Funcionalidades

- Buscar el clima de una ciudad por nombre
- Visualizar temperatura, descripción e ícono del clima
- Guardar ciudades favoritas (persistencia con SharedPreferences)
- Eliminar ciudades favoritas
- Consultar rápidamente el clima de una ciudad favorita con un toque

## Tecnologías

- Flutter
- OpenWeatherMap API
- SharedPreferences

## Estructura

```
lib/
├── main.dart
├── screens/
│   └── home_screen.dart
└── services/
    └── weather_service.dart
```

## Instalación

```bash
flutter pub get
flutter run
```
