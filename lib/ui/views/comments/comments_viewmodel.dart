import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/comments/models/comments_model.dart';
import 'package:blogman/services/http_service.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/utils/strings.dart';
import '../../../app/base/base_viewmodel.dart';

class CommentsViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  CommentsModel? commentsModel;

  void getComments(String? postId) async {
    if (commentsModel != null) return;
    setState(ViewState.busy);

    Map<String, dynamic> data = {"view": "ADMIN"};

    if (postId == null) data['status'] = CommentStatus.pending.name;

    final blogId = locator<HomeViewModel>().blogId;
    final response = await _dio.request(
      url: postId == null
          ? KStrings.getComments(blogId: blogId)
          : KStrings.getPostComments(blogId: blogId, postId: postId),
      method: HttpMethod.get,
      data: data,
    );

    if (response == null) {
      setState(ViewState.idle);
      return;
    }

    commentsModel = CommentsModel.fromJson(response.data);
    setState(ViewState.idle);
  }

  CommentModel? findCommentFromId(String? id) {
    if (id == null) return null;
    try {
      final item = commentsModel!.items.firstWhere((e) => e.id == id);
      return item;
    } catch (e) {
      return null;
    }
  }
}
