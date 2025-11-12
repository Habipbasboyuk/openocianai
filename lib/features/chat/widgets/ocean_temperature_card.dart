import 'package:flutter/material.dart';

class OceanTemperatureCard extends StatelessWidget {
  final String region;
  final double temperature;
  final String unit;

  const OceanTemperatureCard({
    super.key,
    required this.region,
    required this.temperature,
    this.unit = '°C',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              region,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$temperature$unit',
              style: const TextStyle(fontSize: 32, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
