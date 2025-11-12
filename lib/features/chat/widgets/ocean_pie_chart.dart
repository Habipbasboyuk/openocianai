import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../services/favorites_service.dart';
import '../models/favorite.dart';

/// Ocean-themed Pie Chart with screenshot and favorite support.
///
/// Expects `data` as a list of maps: [{ 'label': 'A', 'value': 12.3 }, ...]
class OceanPieChart extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const OceanPieChart({super.key, required this.title, required this.data});

  @override
  State<OceanPieChart> createState() => _OceanPieChartState();
}

class _OceanPieChartState extends State<OceanPieChart> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _takeScreenshot() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
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
    if (widget.data.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text('No data available'),
        ),
      );
    }

    // Prepare pie sections
    final total = widget.data.fold<double>(0.0, (prev, item) {
      final v = (item['value'] as num?)?.toDouble() ?? 0.0;
      return prev + v;
    });

    final colors = [
      const Color(0xFF006994),
      const Color(0xFF4ECDC4),
      const Color(0xFF00BCD4),
      const Color(0xFF00E5FF),
      const Color(0xFFFF6B6B),
      Colors.amber,
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      final value = (item['value'] as num?)?.toDouble() ?? 0.0;
      final percent = total > 0 ? (value / total * 100) : 0.0;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value,
          title: '${percent.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
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
              final pieRadius = isNarrow ? 48.0 : 60.0;

              final pie = SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: sections
                        .map((s) => s.copyWith(radius: pieRadius))
                        .toList(),
                    centerSpaceRadius: isNarrow ? 24 : 30,
                    sectionsSpace: 4,
                  ),
                ),
              );

              final legend = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.data.length, (i) {
                  final item = widget.data[i];
                  final label = item['label']?.toString() ?? 'Item ${i + 1}';
                  final value = (item['value'] as num?)?.toDouble() ?? 0.0;
                  final color = colors[i % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$label — ${value.toStringAsFixed(1)}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );

              final header = Row(
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
                    icon: const Icon(Icons.star_border, color: Colors.amber),
                    tooltip: 'Markeer als favoriet',
                    onPressed: () async {
                      try {
                        final content = jsonEncode(widget.data);
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
                              content: Text('Kon favoriet niet toevoegen: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 12),
                  if (isNarrow) ...[
                    pie,
                    const SizedBox(height: 12),
                    legend,
                  ] else ...[
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: pie),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: legend),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
