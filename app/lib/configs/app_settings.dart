import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  late Box box;
  Map<String, String> _logindata = {
    'registration': 'Estou',
    'password': 'Triste',
  };

  Map<String, String> get logindata {
    _startSetting();
    return _logindata;
  }

  set logindata(Map<String, String> value) {
    _logindata = value;
  }

  AppSettings() {
    _startSetting();
  }

  Future<void> _startSetting() async {
    await _openbox();
    _readData();
  }

  Future<void> _openbox() async {
    box = Hive.box('logindata');
    _readData();
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
