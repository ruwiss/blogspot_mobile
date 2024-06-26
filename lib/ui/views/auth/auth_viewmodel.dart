import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/base/base_viewmodel.dart';
import '../../../core/core.dart';
import '../../../utils/strings.dart';
import 'models/auth_models.dart';

class AuthViewModel extends BaseViewModel {
  bool splash = true;
  final _appSettings = locator<AppSettings>();
  final _firebaseInstance = FirebaseAuth.instance;
  final _googleAuth = GoogleSignIn(scopes: KStrings.authScopes);

  final _dio = locator<HttpService>();

  User? user;
  List<BlogModel>? blogList;
  BlogModel? selectedBlog;
  BlogUserInfoModel? blogUserInfoModel;

  void hideSplash() {
    splash = false;
    notifyListeners();
  }

  // Sayfa açılınca, varsa gönderilen blogModel buraya kaydedilir
  void setBlogList(List<BlogModel>? blogs) {
    blogList = blogs;
    notifyListeners();
  }

  Future<bool> authUser() async {
    setState(ViewState.busy);
    try {
      // Google Auth ile kullanıcı girişi
      final googleSignIn = await _googleAuth.signIn();
      final authentication = await googleSignIn?.authentication;
      if (authentication == null) throw 'Authentication: null';

      // Erişim Tokeni
      final String? accessToken = authentication.accessToken;
      if (accessToken == null) throw 'Access Token: null';

      // Erişim Tokenini isteklerde kullanmak için kaydetme
      setHttpAccessToken(accessToken);

      // Google Auth bilgileriyle kimlik oluşturma
      final authCredential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken);

      // Oluşturulan kimlik ile Firebase girişi sağlama
      final authResult =
          await _firebaseInstance.signInWithCredential(authCredential);

      // Firebase girişi sonrası kullanıcıyı alma
      user = authResult.user;
      if (user == null) throw 'User: null';

      _appSettings.setAuth(true);
      if (kDebugMode) print("Auth Successful");
      FirebaseAnalytics.instance.logEvent(name: 'authSuccessful');
      return true;
    } catch (e) {
      _appSettings.setAuth(false);
      if (kDebugMode) print(e.toString());
      return false;
    } finally {
      setState(ViewState.idle);
    }
  }

  Future<void> signOut() async {
    setState(ViewState.busy);
    await _googleAuth.disconnect();
    await _firebaseInstance.signOut();
    // blog seçimini temizle
    _appSettings.removeSelectedBlog();
    // otomatik girişi kapat
    _appSettings.setAuth(false);
    setState(ViewState.idle);
  }

  void setHttpAccessToken(String accessToken) {
    // tokeni alınca tek seferlik kaydet ve buradan kullan
    locator<HttpService>().setDefaultHeaders(KStrings.httpHeaders(accessToken));
  }

  Future<String?> getUserBlogs() async {
    setState(ViewState.busy);
    final response =
        await _dio.request(url: KStrings.getUserBlogs, method: HttpMethod.get);

    if (response == null) {
      setState(ViewState.idle);
      return 'unknownError'.tr();
    }

    List<BlogModel> blogs = [];
    for (var blog in response.data['items']) {
      blogs.add(BlogModel.fromJson(blog));
    }
    setState(ViewState.idle);

    // Kullanıcı blog sahibi değilse
    if (blogs.isEmpty) return 'noBlog'.tr();

    setBlogList(blogs);
    return null;
  }

  // Kullanıcı blog seçiyor
  void setSelectedBlog(BlogModel? blog) {
    selectedBlog = blog;
    notifyListeners();
  }

  // Yeniden girişte otomatik blog seçimi
  void setSelectedBlogFromMemory() {
    final memory = _appSettings.getSelectedBlogId();
    setSelectedBlog(blogList?.singleWhere((e) => e.id == memory));
  }

  // Kullanıcının seçilen blog üzerinde admin yetkisi var mı?
  Future<bool> checkUserBlogAccess() async {
    await getBlogUserInformation();
    return blogUserInfoModel?.hasAdminAccess ?? false;
  }

  // Kullanıcı blog yetkisini getir
  Future<void> getBlogUserInformation() async {
    setState(ViewState.busy);
    final response = await _dio.request(
        url: KStrings.userBlogInfo(blogId: selectedBlog!.id),
        method: HttpMethod.get);

    if (response != null) {
      blogUserInfoModel =
          BlogUserInfoModel.fromJson(response.data['blog_user_info']);
    }
    setState(ViewState.idle);
  }
}
