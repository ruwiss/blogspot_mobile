import 'package:blogman/app/locator.dart';
import 'package:blogman/services/shared_preferences/settings.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';

import '../../../app/base/base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  void getBlogsIfNotAvailable() async {
    if (locator<AuthViewModel>().blogList != null) return;
    await locator<AuthViewModel>().getUserBlogs();
    locator<AuthViewModel>().setSelectedBlogFromMemory();
  }

  void changeUserBlog(BlogModel blog) {
    locator<AuthViewModel>().setSelectedBlog(blog);
    locator<HomeViewModel>().setBlogId(blog.id);
    locator<AppSettings>().selectBlog(blog.id);
    locator<HomeViewModel>().getContents();
  }
}
