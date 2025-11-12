class FavoritesStorage {
  static final Map<String, String> _inMemory = {};

  String? read(String key) => _inMemory[key];
  void write(String key, String value) => _inMemory[key] = value;
  void remove(String key) => _inMemory.remove(key);
}
