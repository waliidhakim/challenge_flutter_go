import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get token => _sharedPrefs.getString('token') ?? "";

  set token(String value) {
    _sharedPrefs.setString('token', value);
  }
}

final sharedPrefs = SharedPrefs();