import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  late SharedPreferences prefs;

  Future<void> _setup() async => prefs = await SharedPreferences.getInstance();

  Future<bool> isAuth() async {
    await _setup();
    return prefs.getBool('isAuth') ?? false;
  }

  void setAuth(bool value) => prefs.setBool('isAuth', value);

  String? getSelectedBlogId() => prefs.getString('selectedBlogId');
  void selectBlog(String id) => prefs.setString('selectedBlogId', id);
  void removeSelectedBlog() => prefs.remove('selectedBlogId');
}
