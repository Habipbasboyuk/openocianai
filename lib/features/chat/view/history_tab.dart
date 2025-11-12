import 'package:flutter/material.dart';
import '../models/chat_history.dart';
import '../services/chat_history_service.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final ChatHistoryService _historyService = ChatHistoryService();
  List<ChatHistory> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final history = await _historyService.getHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _loading = false;
        });
      }
    } catch (e) {
      // If anything goes wrong, avoid leaving the spinner spinning forever.
      if (mounted) {
        setState(() {
          _history = [];
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kon geschiedenis niet laden: $e')),
        );
      }
    }
  }

  Future<void> _deleteChat(String id) async {
    await _historyService.deleteChat(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              'Geen chat geschiedenis',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final chat = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDark ? const Color(0xFF1A5566) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isDark
                  ? const Color(0xFF00BCD4)
                  : const Color(0xFF006994),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
            title: Text(
              chat.title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${chat.messages.length} berichten',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(chat.timestamp),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.red[300] : Colors.red,
              ),
              onPressed: () => _deleteChat(chat.id),
            ),
            onTap: () {
              // TODO: Toon chat details
              _showChatDetails(context, chat);
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min geleden';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} uur geleden';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dag${diff.inDays == 1 ? '' : 'en'} geleden';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showChatDetails(BuildContext context, ChatHistory chat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A5566) : Colors.white,
        title: Text(
          chat.title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: chat.messages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  chat.messages[index],
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Sluiten',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF00BCD4)
                    : const Color(0xFF006994),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
