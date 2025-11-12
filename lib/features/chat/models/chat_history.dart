class ChatHistory {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<String> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'messages': messages,
    };
  }

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      id: json['id'] as String,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messages: (json['messages'] as List).cast<String>(),
    );
  }
}
