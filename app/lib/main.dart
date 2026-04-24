import 'dart:async';

import 'package:app/configs/app_settings.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/theme/flutter_flow_theme.dart';
import 'configs/hive_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final connectivityService = ConnectivityService();

  await HiveConfig.start();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterFlowTheme.initialize();

  // Nao bloqueia o carregamento inicial caso o plugin de conectividade falhe.
  try {
    await connectivityService.initialize();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppSettings(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (context) => connectivityService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeMode = FlutterFlowTheme.themeMode;
    return MaterialApp(
      title: 'DuckBooks-Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: themeMode,
      home: const LoginPage(),
    );
  }
}
