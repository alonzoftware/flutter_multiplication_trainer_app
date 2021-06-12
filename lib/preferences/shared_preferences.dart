import 'package:shared_preferences/shared_preferences.dart';

class _SharedPrefs {
  late SharedPreferences _prefs;
  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get factor1 => _prefs.getInt('factor1') ?? 0;
  set factor1(int value) => _prefs.setInt('factor1', value);

  int get factor2 => _prefs.getInt('factor2') ?? 0;
  set factor2(int value) => _prefs.setInt('factor2', value);

  int get result => _prefs.getInt('result') ?? 0;
  set result(int value) => _prefs.setInt('result', value);
}

final sharedPrefsService = new _SharedPrefs();
