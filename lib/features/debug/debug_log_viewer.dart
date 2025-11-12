import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class DebugLogViewer extends StatefulWidget {
  const DebugLogViewer({super.key});

  @override
  State<DebugLogViewer> createState() => _DebugLogViewerState();
}

class _DebugLogViewerState extends State<DebugLogViewer> {
  final List<LogRecord> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    Logger.root.onRecord.listen((record) {
      if (mounted) {
        setState(() {
          _logs.add(record);
          // Bewaar max 200 logs
          if (_logs.length > 200) {
            _logs.removeAt(0);
          }
        });

        if (_autoScroll && _scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getColorForLevel(Level level) {
    if (level == Level.SEVERE || level == Level.SHOUT) {
      return Colors.red;
    } else if (level == Level.WARNING) {
      return Colors.orange;
    } else if (level == Level.INFO) {
      return Colors.blue;
    } else if (level == Level.CONFIG) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border(top: BorderSide(color: Colors.grey.shade700, width: 2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Debug Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Auto-scroll toggle
                Row(
                  children: [
                    const Text(
                      'Auto-scroll',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Switch(
                      value: _autoScroll,
                      onChanged: (value) {
                        setState(() {
                          _autoScroll = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                  },
                  tooltip: 'Clear logs',
                ),
              ],
            ),
          ),
          // Logs list
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs yet...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade800,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Level badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getColorForLevel(log.level),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.level.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Logger name
                                Text(
                                  log.loggerName,
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                // Time
                                Text(
                                  '${log.time.hour.toString().padLeft(2, '0')}:'
                                  '${log.time.minute.toString().padLeft(2, '0')}:'
                                  '${log.time.second.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Message
                            Text(
                              log.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            // Error if present
                            if (log.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Error: ${log.error}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
