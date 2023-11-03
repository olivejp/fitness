import 'package:flutter/foundation.dart';

class DebugPrinter {
  static printLn(Object? message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static printError(Object? message, StackTrace? trace) {
    if (kDebugMode) {
      print('\x1B[31m$message\x1B[0m');
    }
  }
}
