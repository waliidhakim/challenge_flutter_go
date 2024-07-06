import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get token => _sharedPrefs.getString('token') ?? "";
  String get userId => _sharedPrefs.getString('userId') ?? "";
  String get username => _sharedPrefs.getString('username') ?? "";

  set token(String value) {
    _sharedPrefs.setString('token', value);
  }

  set userId(String value) {
    _sharedPrefs.setString('userId', value);
  }

  set username(String value) {
    _sharedPrefs.setString('username', value);
  }
}

final sharedPrefs = SharedPrefs();
