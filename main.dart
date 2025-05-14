import 'package:flutter/material.dart';
import 'mqtt_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mqttService = MqttService();
  double temperature = 0.0;
  double humidity = 0.0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    mqttService.onMessageReceived = (data) {
      setState(() {
        temperature = (data['temperature'] ?? 0).toDouble();
        humidity = (data['humidity'] ?? 0).toDouble();
      });
    };
    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue,
      cardTheme: CardTheme(
        elevation: 8,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blue,
      cardTheme: CardTheme(
        elevation: 8,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required double value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Dashboard',
      theme: _getLightTheme(),
      darkTheme: _getDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Sensor Readings'),
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                tooltip: 'Toggle theme',
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.thermostat), text: 'Temperature'),
                Tab(icon: Icon(Icons.water_drop), text: 'Humidity'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(
                child: _buildSensorCard(
                  title: 'Temperature',
                  value: temperature,
                  unit: ' °C',
                  icon: Icons.thermostat,
                  color: _isDarkMode ? Colors.orange[300]! : Colors.orange,
                ),
              ),
              Center(
                child: _buildSensorCard(
                  title: 'Humidity',
                  value: humidity,
                  unit: ' %',
                  icon: Icons.water_drop,
                  color: _isDarkMode ? Colors.blue[300]! : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
