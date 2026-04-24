import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  late Box box;
  Map<String, String> _logindata = {
    'registration': '',
    'password': '',
  };
  bool _isInitialized = false;

  Map<String, String> get logindata {
    return _logindata;
  }

  set logindata(Map<String, String> value) {
    _logindata = value;
  }

  AppSettings() {
    _startSetting();
  }

  Future<void> _startSetting() async {
    if (_isInitialized) {
      return;
    }

    await _openbox();
    _readData();
    _isInitialized = true;
  }

  Future<void> _openbox() async {
    box = Hive.box('logindata');
  }

  void _readData() {
    final registration = box.get('registration') ?? '';
    final senha = box.get('password') ?? '';

    logindata = {
      'registration': registration,
      'password': senha,
    };
    notifyListeners();
  }

  Future<void> setData(String registration, String pass) async {
    await box.put('registration', registration);
    await box.put('password', pass);
    _readData();
    notifyListeners();
  }
}
