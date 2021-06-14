import 'package:shared_preferences/shared_preferences.dart';

class _SharedPrefs {
  // make this nullable by adding '?'
  static _SharedPrefs? _instance;

  _SharedPrefs._() {
    // initialization and stuff
  }

  factory _SharedPrefs() {
    if (_instance == null) {
      _instance = new _SharedPrefs._();
    }
    // since you are sure you will return non-null value, add '!' operator
    return _instance!;
  }

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

  int get base => _prefs.getInt('base') ?? 5;
  set base(int value) => _prefs.setInt('base', value);

  int get minLimit => _prefs.getInt('minLimit') ?? 1;
  set minLimit(int value) => _prefs.setInt('minLimit', value);

  int get maxLimit => _prefs.getInt('maxLimit') ?? 10;
  set maxLimit(int value) => _prefs.setInt('maxLimit', value);
}

final sharedPrefsService = new _SharedPrefs();
