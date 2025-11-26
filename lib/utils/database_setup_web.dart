// Import the necessary web-specific sqflite package
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; 
import 'package:sqflite/sqflite.dart'; 

// This implementation runs on Web
Future<void> initializeDatabaseFactory() async {
  // Set the factory to the web implementation
  databaseFactory = databaseFactoryFfiWeb; 
}