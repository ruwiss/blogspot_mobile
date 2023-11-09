import 'package:blogman/app/locator.dart';
import 'package:blogman/services/http_service.dart';
import 'package:blogman/services/shared_preferences/settings.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/ui/views/profile/models/statistics_model.dart';
import 'package:blogman/utils/strings.dart';

import '../../../app/base/base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  StatisticsModel? statistics;

  void getProfileValues() async {
    await getBlogsIfNotAvailable();
    getStatistics();
  }

  Future<void> getBlogsIfNotAvailable() async {
    if (locator<AuthViewModel>().blogList != null) return;
    await locator<AuthViewModel>().getUserBlogs();
    locator<AuthViewModel>().setSelectedBlogFromMemory();
  }

  void changeUserBlog(BlogModel blog) {
    statistics = null;
    locator<AuthViewModel>().setSelectedBlog(blog);
    locator<HomeViewModel>().setBlogId(blog.id);
    locator<AppSettings>().selectBlog(blog.id);
    locator<HomeViewModel>().getContents();
  }

  Future<void> getStatistics() async {
    if (statistics != null) return;
    setState(ViewState.busy);
    const types = ['7days', '30days', 'all'];
    Map<String, String> values = {};
    for (var type in types) {
      final response = await _dio.request(
          url: KStrings.getStatistics(blogId: locator<HomeViewModel>().blogId),
          method: HttpMethod.get,
          data: {'range': type});
      if (response == null) {
        setState(ViewState.idle);
        break;
      }
      values[type] = response.data['counts'][0]['count'];
    }
    statistics = StatisticsModel.fromJson(values);
    setState(ViewState.idle);
  }
}
