import 'dart:html' as html;

class FavoritesStorage {
  String? read(String key) => html.window.localStorage[key];
  void write(String key, String value) => html.window.localStorage[key] = value;
  void remove(String key) => html.window.localStorage.remove(key);
}
