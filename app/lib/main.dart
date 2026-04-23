import 'dart:async';
import 'dart:ui' as ui;

import 'package:app/configs/app_settings.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/theme/flutter_flow_theme.dart';
import 'configs/hive_config.dart';
import 'firebase_options.dart';

final ValueNotifier<String?> _fatalErrorNotifier = ValueNotifier<String?>(null);

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _fatalErrorNotifier.value =
        '${details.exceptionAsString()}\n\n${details.stack ?? ''}';
  };

  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _fatalErrorNotifier.value = '$error\n\n$stack';
    return true;
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveConfig.start();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FlutterFlowTheme.initialize();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AppSettings(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthService(),
          ),
        ],
        child: MyApp(errorNotifier: _fatalErrorNotifier),
      ),
    );
  }, (Object error, StackTrace stack) {
    _fatalErrorNotifier.value = '$error\n\n$stack';
    runApp(
      MyApp(errorNotifier: _fatalErrorNotifier),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.errorNotifier});

  final ValueNotifier<String?> errorNotifier;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: errorNotifier,
      builder: (context, errorMessage, _) {
        final themeMode = FlutterFlowTheme.themeMode;
        return MaterialApp(
          title: 'DuckBooks-Web',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: themeMode,
          home: errorMessage == null
              ? const LoginPage()
              : _FatalErrorScreen(message: errorMessage),
        );
      },
    );
  }
}

class _FatalErrorScreen extends StatelessWidget {
  const _FatalErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3DFD2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: SelectableText(
              'Erro de inicializacao ou runtime:\n\n$message',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
