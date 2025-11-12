import 'package:flutter/material.dart';
import 'package:hack_the_future_starter/features/chat/widgets/ocean_line_chart.dart';

/// Demo screen die laat zien hoe de OceanLineChart werkt
class ChartDemoScreen extends StatelessWidget {
  const ChartDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Voorbeeld data: temperatuur over 7 dagen
    final temperatureData = [
      {'x': 0, 'y': 14.2},
      {'x': 1, 'y': 14.8},
      {'x': 2, 'y': 15.1},
      {'x': 3, 'y': 14.5},
      {'x': 4, 'y': 15.8},
      {'x': 5, 'y': 16.2},
      {'x': 6, 'y': 15.9},
    ];

    // Voorbeeld data: saliniteit
    final salinityData = [
      {'x': 0, 'y': 34.5},
      {'x': 1, 'y': 34.8},
      {'x': 2, 'y': 35.1},
      {'x': 3, 'y': 34.9},
      {'x': 4, 'y': 35.3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocean Charts Demo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Voorbeeld 1: Temperatuur grafiek
            OceanLineChart(
              title: 'North Sea Temperature (Last 7 Days)',
              dataPoints: temperatureData,
              xLabel: 'Days',
              yLabel: 'Temperature (°C)',
            ),

            const SizedBox(height: 16),

            // Voorbeeld 2: Saliniteit grafiek
            OceanLineChart(
              title: 'Atlantic Ocean Salinity',
              dataPoints: salinityData,
              xLabel: 'Measurement Points',
              yLabel: 'Salinity (PSU)',
            ),

            const SizedBox(height: 16),

            // Instructies
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hoe te gebruiken:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Vraag Gemini in de chat om data te visualiseren\n'
                        '2. Gemini kan deze charts gebruiken om trends te tonen\n'
                        '3. De charts werken met simpele data points (x, y)',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Voorbeeld vragen aan Gemini:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• "Toon de temperatuur trend in de Noordzee"',
                            ),
                            SizedBox(height: 4),
                            Text('• "Visualiseer de saliniteit data"'),
                            SizedBox(height: 4),
                            Text('• "Laat me de golfhoogte over tijd zien"'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
