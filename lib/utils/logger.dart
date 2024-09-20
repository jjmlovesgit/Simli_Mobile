import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

///logger object for logging
final Logger log = Logger('Simli Client');

///it will initialize the logger for the app
void initializeLogger({Level level = kDebugMode ? Level.ALL : Level.SEVERE}) {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((LogRecord record) {
    final text = '${record.time}: ${record.message}';
    if (<Level>[Level.WARNING, Level.SEVERE, Level.SHOUT]
        .contains(record.level)) {
      _debugPrintColoredLine(text, 'red');
    } else if (<Level>[
      Level.FINE,
    ].contains(record.level)) {
      _debugPrintColoredLine(text, 'green');
    } else {
      _debugPrintColoredLine(text, 'yellow');
    }
  });
}

///it will log using info method
void logSuccess(dynamic data) {
  log.fine(data.toString());
}

///it will log using info method
void logInfo(dynamic data) {
  log.info(data.toString());
}

///it will log using serve method
void logException(dynamic data) {
  log.shout(data.toString());
}

void _debugPrintColoredLine(String message, String color) {
  // Check if the provided color is supported
  if (!ansiColors.containsKey(color)) {
    debugPrint('Unsupported color: $color');
    return;
  }
  if (!kIsWeb && Platform.isIOS) {
    dev.log('${ansiColors[color]}$message$resetColor');
  } else {
    // Print message with the specified color
    debugPrint('${ansiColors[color]}$message$resetColor');
  }
}

/// ANSI escape codes for colors
const Map<String, String> ansiColors = <String, String>{
  'red': '\x1B[31m',
  'green': '\x1B[32m',
  'yellow': '\x1B[33m',
};

/// ANSI escape code to reset color
const String resetColor = '\x1B[0m';
