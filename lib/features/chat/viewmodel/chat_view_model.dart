import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/services/genui_service.dart';
import 'package:hack_the_future_starter/features/chat/services/dummy_ocean_responses.dart';
import 'package:logging/logging.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({GenUiService? service}) : _service = service ?? GenUiService();

  static final _log = Logger('ChatViewModel');

  final GenUiService _service;

  late final Catalog _catalog;
  late final GenUiManager _manager;
  late GenUiConversation _conversation;

  int _currentRequestId = 0;

  GenUiHost get host => _conversation.host;

  ValueListenable<bool> get isProcessing => _conversation.isProcessing;

  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  void init() {
    _log.info('Initializing ChatViewModel');
    _catalog = _service.createCatalog();
    _manager = GenUiManager(catalog: _catalog);
    _createConversation();
    _log.info('ChatViewModel initialized successfully');
  }

  void _createConversation() {
    final generator = _service.createContentGenerator(catalog: _catalog);
    final requestIdAtCreation = _currentRequestId;
    bool surfaceAddedForThisRequest = false;
    bool errorHandledForThisRequest = false; // Voorkom dubbele error handling

    _conversation = GenUiConversation(
      genUiManager: _manager,
      contentGenerator: generator,
      onSurfaceAdded: (s) {
        if (requestIdAtCreation != _currentRequestId) {
          _log.warning(
            'Surface ignored - request was canceled (old ID: $requestIdAtCreation, current: $_currentRequestId)',
          );
          _addDebugMessage('⚠️ Request canceled');
          return;
        }
        _log.info('Surface added: ${s.surfaceId}');
        _addDebugMessage('✅ UI component generated');
        surfaceAddedForThisRequest = true;
        _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
        notifyListeners();
      },
      onTextResponse: (text) {
        if (requestIdAtCreation != _currentRequestId) {
          _log.warning(
            'Text response ignored - request was canceled (old ID: $requestIdAtCreation, current: $_currentRequestId)',
          );
          _addDebugMessage('⚠️ Response ignored - canceled');
          return;
        }
        // Skip text response als er al een surface is toegevoegd
        if (surfaceAddedForThisRequest) {
          _log.info('Skipping text response - surface already added');
          surfaceAddedForThisRequest = false; // Reset voor volgende request
          return;
        }
        _log.info('Text response received: $text');
        _addDebugMessage('✅ Text response received');
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
      },
      onError: (err) {
        if (requestIdAtCreation != _currentRequestId) {
          _log.warning(
            'Error ignored - request was canceled (old ID: $requestIdAtCreation, current: $_currentRequestId)',
          );
          return;
        }

        // Voorkom dubbele error handling
        if (errorHandledForThisRequest) {
          _log.warning('Error already handled for this request - skipping');
          return;
        }
        errorHandledForThisRequest = true;

        _log.severe('Error occurred: ${err.error}');

        // Check of Gemini API overloaded/plat ligt
        final errorMsg = err.error.toString().toLowerCase();

        if (errorMsg.contains('overloaded') ||
            errorMsg.contains('resource exhausted')) {
          // Gebruik dummy response ALLEEN als Gemini plat ligt
          _log.warning('🤖 Gemini API down - using dummy response');
          _addDebugMessage('🤖 API overloaded - using demo mode');
          final lastUserMessage = _messages.lastWhere(
            (msg) => msg.isUser,
            orElse: () => ChatMessageModel(text: 'help', isUser: true),
          );

          final dummyResponse = DummyOceanResponses.generateResponse(
            lastUserMessage.text ?? 'help',
          );

          _messages.add(ChatMessageModel(text: dummyResponse, isUser: false));
          notifyListeners();
        } else if (errorMsg.contains('quota') ||
            errorMsg.contains('rate limit')) {
          // Rate limit errors krijgen vriendelijke error message
          _addDebugMessage('⚠️ Rate limit hit');
          _messages.add(
            ChatMessageModel(
              text:
                  '⚠️ Rate limit exceeded. Please wait before sending more requests.',
              isError: true,
            ),
          );
          notifyListeners();
        } else {
          // Andere errors gewoon tonen
          _addDebugMessage('⚠️ Error: ${err.error}');
          _messages.add(
            ChatMessageModel(text: err.error.toString(), isError: true),
          );
          notifyListeners();
        }
      },
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    _log.info('Sending message: $text');
    _messages.add(ChatMessageModel(text: text, isUser: true));
    _addDebugMessage('🚀 Sending to Gemini AI...');
    notifyListeners();
    await _conversation.sendRequest(UserMessage([TextPart(text)]));
    _log.info('Message sent successfully');
  }

  void _addDebugMessage(String message) {
    // Voeg klein debug bericht toe dat niet als user of error gemarkeerd is
    final debugMsg = ChatMessageModel(
      text: message,
      isUser: false,
      isError: false,
    );
    _messages.add(debugMsg);
    notifyListeners();

    // Verwijder het bericht na 3 seconden
    Timer(const Duration(seconds: 3), () {
      _messages.remove(debugMsg);
      notifyListeners();
    });
  }

  void cancelCurrentRequest() {
    _log.warning('Canceling current request - incrementing request ID');
    _currentRequestId++; // Verhoog ID zodat oude callbacks genegeerd worden
    _log.info('Request ID changed to: $_currentRequestId');

    // Dispose oude conversation
    _log.info('Disposing old conversation');
    final oldConversation = _conversation;

    // Maak EERST nieuwe conversation
    _log.info('Creating fresh conversation');
    _createConversation();

    // Dan pas dispose de oude
    oldConversation.dispose();

    // Voeg cancel bericht toe
    _addDebugMessage('❌ Request canceled');
    notifyListeners();

    _log.info('Conversation reset complete - ready for new requests');
  }

  void disposeConversation() {
    _conversation.dispose();
  }
}
