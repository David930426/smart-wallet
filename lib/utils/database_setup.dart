// Ignore the unused import warnings, they are necessary for platform compatibility
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

// This implementation runs on Desktop (Windows/Linux/macOS) and Mobile
Future<void> initializeDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}