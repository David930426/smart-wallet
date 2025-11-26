// You must have sqflite_common_ffi_web added to pubspec.yaml
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; 
import 'package:sqflite/sqflite.dart';

Future<void> initializeDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}