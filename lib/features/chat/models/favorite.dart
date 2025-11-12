class Favorite {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final FavoriteType type;

  Favorite({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: FavoriteType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FavoriteType.text,
      ),
    );
  }
}

enum FavoriteType { text, chart }
