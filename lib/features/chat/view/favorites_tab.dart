import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../services/favorites_service.dart';
import '../widgets/ocean_line_chart.dart';
import '../widgets/ocean_pie_chart.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final FavoritesService _service = FavoritesService();
  List<Favorite> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _service.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String id) async {
    await _service.removeFavorite(id);
    _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favoriet verwijderd'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFavoriteDetails(Favorite favorite) {
    showDialog(
      context: context,
      builder: (context) {
        Widget contentWidget = SingleChildScrollView(
          child: Text(favorite.content),
        );

        if (favorite.type == FavoriteType.chart) {
          try {
            final parsed = jsonDecode(favorite.content);
            if (parsed is List) {
              // Determine if it's line data (x/y) or pie data (label/value)
              final first = parsed.isNotEmpty
                  ? (parsed.first as Map<String, dynamic>)
                  : <String, dynamic>{};
              if (first.containsKey('x') && first.containsKey('y')) {
                final previewHeight = min(
                  320.0,
                  MediaQuery.of(context).size.height * 0.45,
                );
                contentWidget = ClipRect(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: previewHeight,
                    child: OceanLineChart(
                      title: favorite.title,
                      dataPoints: parsed.cast<Map<String, dynamic>>(),
                    ),
                  ),
                );
              } else if (first.containsKey('label') &&
                  first.containsKey('value')) {
                final previewHeight = min(
                  320.0,
                  MediaQuery.of(context).size.height * 0.45,
                );
                contentWidget = ClipRect(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: previewHeight,
                    child: OceanPieChart(
                      title: favorite.title,
                      data: parsed.cast<Map<String, dynamic>>(),
                    ),
                  ),
                );
              }
            }
          } catch (_) {
            // fallback leaves contentWidget as the raw text
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                favorite.type == FavoriteType.chart
                    ? Icons.show_chart
                    : Icons.message,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(favorite.title)),
            ],
          ),
          content: contentWidget,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Net nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minuten geleden';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} uur geleden';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dagen geleden';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? const Color(0xFF00BCD4) : const Color(0xFF006994),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            const SizedBox(height: 16),
            Text(
              'Geen favorieten',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Markeer interessante resultaten met een ster',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: isDark ? const Color(0xFF0D3B4D) : const Color(0xFFFFF4E6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? const Color(0xFF1A5566) : Colors.white,
            child: ListTile(
              leading: Icon(
                favorite.type == FavoriteType.chart
                    ? Icons.show_chart
                    : Icons.message,
                color: Colors.amber,
                size: 32,
              ),
              title: Text(
                favorite.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (favorite.type == FavoriteType.chart) ...[
                    // Try to render a small preview of the chart
                    Builder(
                      builder: (context) {
                        try {
                          final parsed = jsonDecode(favorite.content);
                          if (parsed is List) {
                            final first = parsed.isNotEmpty
                                ? (parsed.first as Map<String, dynamic>)
                                : <String, dynamic>{};
                            if (first.containsKey('x') &&
                                first.containsKey('y')) {
                              final previewHeight = min(
                                320.0,
                                MediaQuery.of(context).size.height * 0.45,
                              );
                              return ClipRect(
                                child: SizedBox(
                                  // Make preview as tall as reasonably possible in the list
                                  height: previewHeight,
                                  child: OceanLineChart(
                                    title: favorite.title,
                                    dataPoints: parsed
                                        .cast<Map<String, dynamic>>(),
                                  ),
                                ),
                              );
                            } else if (first.containsKey('label') &&
                                first.containsKey('value')) {
                              final previewHeight = min(
                                320.0,
                                MediaQuery.of(context).size.height * 0.45,
                              );
                              return ClipRect(
                                child: SizedBox(
                                  // Make preview as tall as reasonably possible in the list
                                  height: previewHeight,
                                  child: OceanPieChart(
                                    title: favorite.title,
                                    data: parsed.cast<Map<String, dynamic>>(),
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (_) {
                          // fall through to text preview
                        }
                        return Text(
                          favorite.content,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ] else ...[
                    Text(
                      favorite.content,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(favorite.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeFavorite(favorite.id),
              ),
              onTap: () => _showFavoriteDetails(favorite),
            ),
          );
        },
      ),
    );
  }
}
