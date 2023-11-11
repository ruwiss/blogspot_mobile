import 'package:blogman/enums/post_filter_enum.dart';
import 'package:blogman/ui/views/comments/models/comments_model.dart';

abstract class KStrings {
  static const String appName = 'Blogspot Mobile';
  static const List<String> authScopes = [
    "https://www.googleapis.com/auth/blogger",
    "https://www.googleapis.com/auth/blogger.readonly"
  ];

  static Map<String, dynamic> httpHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $accessToken",
        'X-Android-Package': "com.rw.blogspot",
        'X-Android-Cert':
            "A1:E6:AA:A8:08:C9:2A:56:16:EE:2A:5C:BD:D5:22:36:A1:03:60:58",
      };

  static const String privacyPolicyUrl =
      "https://kodlayalim.net/docs/bloggerPrivacyPolicy.html";

  static const String createBlogUrl = "https://www.blogger.com/";

  // API
  static const String getUserBlogs =
      "https://www.googleapis.com/blogger/v3/users/self/blogs";

  static String userBlogInfo({required String blogId}) =>
      "https://www.googleapis.com/blogger/v3/users/self/blogs/$blogId";

  static String getContentList(
          {required String blogId, required PostFilter type}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/${type.name}";

  static String getDraftList(
          {required String blogId, required PostFilter draftType}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/${draftType.name}";

  static String getSearchList({required String blogId}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/search";

  static String getStatistics({required String blogId}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/pageviews";

  static String getComments({required String blogId}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/comments";

  static String getPostComments(
          {required String blogId, required String postId}) =>
      "https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/$postId/comments";

  static String deleteComment(CommentModel comment) =>
      "https://www.googleapis.com/blogger/v3/blogs/${comment.blogId}/posts/${comment.postId}/comments/${comment.id}";

  static String spamComment(CommentModel comment) =>
      "https://www.googleapis.com/blogger/v3/blogs/${comment.blogId}/posts/${comment.postId}/comments/${comment.id}/spam";

  static String approveComment(CommentModel comment) =>
      "https://www.googleapis.com/blogger/v3/blogs/${comment.blogId}/posts/${comment.postId}/comments/${comment.id}/approve";
}
