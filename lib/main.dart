// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/db_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init local db
  await DbService.db;

  // init notifications + schedule 9pm daily reminder
  await NotificationService.init();
  await NotificationService.scheduleDaily9pmReminder();

  runApp(const ProviderScope(child: DayLogApp()));
}
