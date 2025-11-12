import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OceanLineChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> dataPoints;
  final String xLabel;
  final String yLabel;

  const OceanLineChart({
    super.key,
    required this.title,
    required this.dataPoints,
    this.xLabel = 'Time',
    this.yLabel = 'Value',
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    // Converteer data naar FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final x = (point['x'] as num?)?.toDouble() ?? i.toDouble();
      final y = (point['y'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(x, y));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        yLabel,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        xLabel,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: null, // Auto calculate
                  maxY: null, // Auto calculate
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
