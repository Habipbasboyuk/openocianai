import 'package:logging/logging.dart';

/// Utility class voor dummy ocean data responses
class DummyOceanResponses {
  static final _log = Logger('DummyOceanResponses');

  static String generateResponse(String userText) {
    _log.info('🤖 Generating dummy response (Gemini unavailable)');

    final lowerText = userText.toLowerCase();

    if (lowerText.contains('temperature') ||
        lowerText.contains('temperatuur')) {
      return _generateTemperatureResponse();
    } else if (lowerText.contains('chart') ||
        lowerText.contains('graph') ||
        lowerText.contains('grafiek') ||
        lowerText.contains('trend')) {
      return _generateChartResponse();
    } else if (lowerText.contains('salinity') ||
        lowerText.contains('saliniteit')) {
      return _generateSalinityResponse();
    } else if (lowerText.contains('wave') || lowerText.contains('golf')) {
      return _generateWaveResponse();
    } else {
      return _generateDefaultResponse();
    }
  }

  static String _generateTemperatureResponse() {
    return '''
🌡️ **North Sea Temperature Data** (Demo Mode)

Current conditions:
• Average: 15.2°C
• Min: 12.1°C  
• Max: 18.5°C
• Trend: Slightly warming

📊 Recent measurements show stable conditions across the region.

*Note: This is dummy data. Gemini API is currently unavailable.*
''';
  }

  static String _generateChartResponse() {
    return '''
📈 **Ocean Data Visualization** (Demo Mode)

I would normally generate an interactive chart here, but I'm running in demo mode.

Example data points:
• Day 1: 14.2°C
• Day 2: 14.8°C  
• Day 3: 15.1°C
• Day 4: 14.5°C
• Day 5: 15.8°C

*Note: Connect to Gemini API for real visualizations.*
''';
  }

  static String _generateSalinityResponse() {
    return '''
🧂 **Salinity Levels** (Demo Mode)

Current measurements:
• Average: 35.1 PSU
• Range: 34.5 - 35.7 PSU
• Status: Normal levels

Salinity appears stable across monitored regions.

*Note: This is dummy data. Real-time data requires Gemini API.*
''';
  }

  static String _generateWaveResponse() {
    return '''
🌊 **Wave Conditions** (Demo Mode)

Current wave data:
• Average height: 1.2m
• Max observed: 2.4m
• Period: 5-7 seconds
• Conditions: Moderate

*Note: This is simulated data while Gemini API is unavailable.*
''';
  }

  static String _generateDefaultResponse() {
    return '''
🌊 **Ocean AI Assistant** (Demo Mode)

I'm your ocean data assistant! I can help with:

• 🌡️ Temperature analysis
• 📊 Data visualization  
• 🧂 Salinity measurements
• 🌊 Wave conditions
• 📈 Historical trends

Currently running in demo mode because the Gemini API is unavailable.

Try asking:
• "Show me temperature trends"
• "What's the salinity level?"
• "Create a chart of recent data"

*Reconnect to Gemini for real AI-powered responses.*
''';
  }
}
