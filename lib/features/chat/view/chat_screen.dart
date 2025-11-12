import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/features/debug/debug_log_viewer.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:hack_the_future_starter/core/theme/theme_notifier.dart';
import 'package:hack_the_future_starter/core/widgets/ocean_background.dart';

import '../models/chat_message.dart';
import '../viewmodel/chat_view_model.dart';
import '../services/favorites_service.dart';
import '../models/favorite.dart';
import 'history_tab.dart';
import 'favorites_tab.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatViewModel _viewModel;
  late final TabController _tabController;
  bool _showDebugPanel = false; // Debug panel uitgeschakeld

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel()..init();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _viewModel.disposeConversation();
    _textController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _viewModel.send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let background show through
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF00BCD4), const Color(0xFF00E5FF)]
                  : [const Color(0xFF006994), const Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Wave icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.waves,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CookedCodersAi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Laten we er in duiken oceaanliefhebbers!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Theme toggle + Debug toggle + Save button
                  Row(
                    children: [
                      // Save chat button
                      IconButton(
                        icon: const Icon(Icons.save, color: Colors.white),
                        onPressed: () async {
                          try {
                            await _viewModel.saveCurrentChat();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Chat opgeslagen!'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Bekijk',
                                    onPressed: () {
                                      // Switch to History tab so user can verify
                                      _tabController.animateTo(1);
                                    },
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kon chat niet opslaan: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        },
                        tooltip: 'Bewaar chat',
                      ),
                      // Dark/Light mode toggle
                      ValueListenableBuilder<bool>(
                        valueListenable: ThemeNotifier.isDarkMode,
                        builder: (context, isDark, _) {
                          return IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              ThemeNotifier.isDarkMode.value = !isDark;
                            },
                            tooltip: isDark ? 'Light mode' : 'Dark mode',
                          );
                        },
                      ),
                      // Debug toggle
                      IconButton(
                        icon: Icon(
                          _showDebugPanel
                              ? Icons.bug_report
                              : Icons.bug_report_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _showDebugPanel = !_showDebugPanel;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated ocean background
          const Positioned.fill(child: OceanBackground()),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Tab Bar
                Container(
                  color: isDark
                      ? const Color(0xFF0D3B4D).withOpacity(0.7)
                      : const Color(0xFFFFF4E6).withOpacity(0.7),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: isDark
                        ? const Color(0xFF00BCD4)
                        : const Color(0xFF006994),
                    labelColor: isDark
                        ? const Color(0xFF00BCD4)
                        : const Color(0xFF006994),
                    unselectedLabelColor: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    tabs: const [
                      Tab(icon: Icon(Icons.chat), text: 'Chat'),
                      Tab(icon: Icon(Icons.history), text: 'Geschiedenis'),
                      Tab(icon: Icon(Icons.star), text: 'Favorieten'),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Chat Tab
                      _buildChatTab(l10n, isDark),
                      // History Tab
                      const HistoryTab(),
                      // Favorites Tab
                      const FavoritesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(AppLocalizations l10n, bool isDark) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _viewModel.messages.length,
                itemBuilder: (_, i) {
                  final m = _viewModel.messages[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MessageView(m, _viewModel.host, l10n),
                  );
                },
              ),
            ),
            // Input field met debug logs tijdens processing
            ValueListenableBuilder<bool>(
              valueListenable: _viewModel.isProcessing,
              builder: (_, isProcessing, __) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B4D),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Debug logs tijdens processing
                      if (isProcessing && _showDebugPanel)
                        Container(
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A5566),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00BCD4),
                              width: 1,
                            ),
                          ),
                          child: const DebugLogViewer(),
                        ),
                      // Input row
                      Row(
                        children: [
                          // Loading indicator als processing
                          if (isProcessing)
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A5566),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF00BCD4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFFFF6B6B),
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _viewModel.cancelCurrentRequest(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A5566)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2A6577)
                                      : const Color(0xFF006994),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _textController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                enabled: !isProcessing,
                                decoration: InputDecoration(
                                  hintText: isProcessing
                                      ? 'AI aan het denken...'
                                      : 'Typ je bericht...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.4),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00BCD4), Color(0xFF00E5FF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: isProcessing ? null : _send,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView(this.model, this.host, this.l10n);

  final ChatMessageModel model;
  final GenUiHost host;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceId = model.surfaceId;
    final isUser = model.isUser;
    final isError = model.isError;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Timestamp
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (surfaceId == null) {
      final content = model.text ?? '';

      // Check of het een debug message is (begint met specifieke emoji's EN is kort)
      // Dummy responses zijn lang, dus die sluiten we uit
      final isDebugMessage =
          content.length < 100 &&
          (content.startsWith('🚀') ||
              content.startsWith('✅') ||
              content.startsWith('⚠️') ||
              content.startsWith('❌') ||
              content.startsWith('🤖'));

      // Debug messages centraal en klein tonen
      if (isDebugMessage) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (isDark ? const Color(0xFF1A5566) : const Color(0xFFB0D4E3))
                      .withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }

      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0xFF8B3A3A)
                      : isUser
                      ? (isDark
                            ? const Color(0xFF1A5566)
                            : const Color(0xFF006994))
                      : (isDark
                            ? const Color(0xFF2A6577)
                            : const Color(0xFF80D0F0)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white, // Altijd wit in bubbles
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    // Favorite button
                    IconButton(
                      icon: const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final content = model.text ?? '';
                        if (content.trim().isEmpty) return;
                        try {
                          await FavoritesService().addFavorite(
                            title: content.length > 60
                                ? '${content.substring(0, 57)}...'
                                : content,
                            content: content,
                            type: FavoriteType.text,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Toegevoegd aan favorieten'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
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
              ),
            ],
          ),
        ),
      );
    }

    // Voor GenUI surfaces
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A6577),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GenUiSurface(host: host, surfaceId: surfaceId),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                timeStr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
