import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  late SharedPreferences prefs;

  // Shared Preferences nesnesi oluşturuyoruz
  Future<void> _setup() async => prefs = await SharedPreferences.getInstance();

  // Kullanıcı daha önceden giriş yaptı mı
  Future<bool> isAuth() async {
    await _setup();
    return prefs.getBool('isAuth') ?? false;
  }

  // Kullanıcı girişini otomatik giriş için kaydet
  void setAuth(bool value) => prefs.setBool('isAuth', value);

  // Seçilen blogu otomatik giriş için kaydet
  String? getSelectedBlogId() => prefs.getString('selectedBlogId');

  // Kullanıcının seçtiği blogu kaydet
  void selectBlog(String id) => prefs.setString('selectedBlogId', id);

  // Kullanıcının seçtiği blogu sil
  void removeSelectedBlog() => prefs.remove('selectedBlogId');
}
