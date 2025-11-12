import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite.dart';
// Conditional storage fallback (web localStorage or in-memory)
import 'favorites_storage_stub.dart'
    if (dart.library.html) 'favorites_storage_web.dart';

class FavoritesService {
  static const String _key = 'favorites';

  Future<List<Favorite>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_key);
      if (favoritesJson == null) return [];
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((json) => Favorite.fromJson(json)).toList();
    } on MissingPluginException catch (_) {
      // Fallback to web/local in-memory storage
      final stored = FavoritesStorage().read(_key);
      if (stored == null) return [];
      final List<dynamic> decoded = jsonDecode(stored);
      return decoded.map((json) => Favorite.fromJson(json)).toList();
    }
  }

  Future<void> addFavorite({
    required String title,
    required String content,
    required FavoriteType type,
  }) async {
    final favorites = await getFavorites();
    final newFavorite = Favorite(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );
    favorites.insert(0, newFavorite); // Nieuwste eerst
    final String encoded = jsonEncode(
      favorites.map((f) => f.toJson()).toList(),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, encoded);
    } on MissingPluginException catch (_) {
      FavoritesStorage().write(_key, encoded);
    }
  }

  Future<void> removeFavorite(String id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.id == id);
    final String encoded = jsonEncode(
      favorites.map((f) => f.toJson()).toList(),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, encoded);
    } on MissingPluginException catch (_) {
      FavoritesStorage().write(_key, encoded);
    }
  }

  Future<bool> isFavorite(String content) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.content == content);
  }

  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } on MissingPluginException catch (_) {
      FavoritesStorage().remove(_key);
    }
  }
}
