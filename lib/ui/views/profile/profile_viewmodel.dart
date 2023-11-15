import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/ui/views/profile/models/statistics_model.dart';
import 'package:blogman/utils/strings.dart';

import '../../../app/base/base_viewmodel.dart';
import '../../../commons/services/http_service.dart';
import '../../../commons/services/shared_preferences/settings.dart';

class ProfileViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  StatisticsModel? statistics;

  // Profil verilerini getir
  void getProfileValues() async {
    // İlk girişte bloglar geliyor ancak diğer girişlerde otomatik giriş
    // nedeniyle tekrar çekmek gerekiyor
    await getBlogsIfNotAvailable();

    // İstatistikleri getir
    getStatistics();
  }

  // Bloglar çekilmediyse çek
  Future<void> getBlogsIfNotAvailable() async {
    if (locator<AuthViewModel>().blogList != null) return;
    await locator<AuthViewModel>().getUserBlogs();
    locator<AuthViewModel>().setSelectedBlogFromMemory();
  }

  // Kullanıcının mevcut blogunu değiştir
  void changeUserBlog(BlogModel blog) {
    // İstatistik verilerini sıfırla
    statistics = null;
    // Auth ve Home ekranlarındaki state verisini yeni blog ile güncelle
    locator<AuthViewModel>().setSelectedBlog(blog);
    locator<HomeViewModel>().setBlogId(blog.id);
    locator<AppSettings>().selectBlog(blog.id);
    locator<HomeViewModel>().getContents();
  }

  // Mevcut blogun istatistik verilerini getir
  Future<void> getStatistics() async {
    if (statistics != null) return;
    setState(ViewState.busy);

    // 1 haftalık, 1 aylık ve tüm veriler olarak ayrı ayrı getir
    const types = ['7days', '30days', 'all'];
    Map<String, String> values = {};

    for (var type in types) {
      final response = await _dio.request(
          url: KStrings.getStatistics(blogId: locator<HomeViewModel>().blogId),
          method: HttpMethod.get,
          data: {'range': type});

      if (response == null) {
        setState(ViewState.idle);
        return;
      }

      values[type] = response.data['counts'][0]['count'];
    }
    statistics = StatisticsModel.fromJson(values);
    setState(ViewState.idle);
  }
}
