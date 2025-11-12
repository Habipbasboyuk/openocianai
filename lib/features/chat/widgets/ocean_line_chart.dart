import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../services/favorites_service.dart';
import '../models/favorite.dart';

class OceanLineChart extends StatefulWidget {
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
  State<OceanLineChart> createState() => _OceanLineChartState();
}

class _OceanLineChartState extends State<OceanLineChart> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _takeScreenshot() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
        // Download als PNG
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${widget.title.replaceAll(' ', '_')}.png')
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grafiek screenshot gedownload!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij screenshot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text('No data available'),
        ),
      );
    }

    // Converteer data naar FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < widget.dataPoints.length; i++) {
      final point = widget.dataPoints[i];
      final x = (point['x'] as num?)?.toDouble() ?? i.toDouble();
      final y = (point['y'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(x, y));
    }

    return Screenshot(
      controller: _screenshotController,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              // Calculate desired chart width based on number of points (approx 40px per point)
              final desiredWidth = (spots.length * 40).toDouble();
              final chartWidth = desiredWidth > constraints.maxWidth
                  ? desiredWidth
                  : constraints.maxWidth;

              final leftReserved = isNarrow ? 32.0 : 40.0;
              final bottomReserved = isNarrow ? 24.0 : 30.0;

              final chart = SizedBox(
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
                          widget.yLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: leftReserved,
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
                          widget.xLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: bottomReserved,
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
                    // Set X axis bounds if we have explicit x values
                    minX: spots.isNotEmpty ? spots.first.x : 0,
                    maxX: spots.isNotEmpty ? spots.last.x : 0,
                  ),
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        tooltip: 'Screenshot maken',
                        onPressed: _takeScreenshot,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                        ),
                        tooltip: 'Markeer als favoriet',
                        onPressed: () async {
                          try {
                            final content = jsonEncode(widget.dataPoints);
                            await FavoritesService().addFavorite(
                              title: widget.title,
                              content: content,
                              type: FavoriteType.chart,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Grafiek toegevoegd aan favorieten',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kon favoriet niet toevoegen: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Horizontal scrolling if chart is wider than available width
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: chartWidth,
                      ),
                      child: chart,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
