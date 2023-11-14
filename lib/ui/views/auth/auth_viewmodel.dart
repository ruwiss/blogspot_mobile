import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/auth/models/blog_user_info_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/base/base_viewmodel.dart';
import '../../../services/http_service.dart';
import '../../../services/shared_preferences/settings.dart';
import '../../../utils/strings.dart';

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
    _appSettings.removeSelectedBlog();
    _appSettings.setAuth(false);
    setState(ViewState.idle);
  }

  void setHttpAccessToken(String accessToken) {
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

    if (blogs.isEmpty) return 'noBlog'.tr();

    setBlogList(blogs);
    return null;
  }

  void setSelectedBlog(BlogModel? blog) {
    selectedBlog = blog;
    notifyListeners();
  }

  void setSelectedBlogFromMemory() {
    final memory = _appSettings.getSelectedBlogId();
    setSelectedBlog(blogList?.singleWhere((e) => e.id == memory));
  }

  Future<bool> checkUserBlogAccess() async {
    await getBlogUserInformation();
    return blogUserInfoModel?.hasAdminAccess ?? false;
  }

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
