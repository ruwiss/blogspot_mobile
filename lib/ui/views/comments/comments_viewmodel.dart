import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/comments/models/comments_model.dart';
import 'package:blogman/services/http_service.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/utils/strings.dart';
import '../../../app/base/base_viewmodel.dart';

class CommentsViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  CommentsModel? commentsModel;
  String? _commentToken;

  // Yorumları getir
  Future<void> getComments(
      {String? commentUrl,
      bool isPending = false,
      bool isLoadMore = false}) async {
    if (!isLoadMore) setState(ViewState.busy);

    Map<String, dynamic> data = {"view": "ADMIN"};
    if (isLoadMore) data['pageToken'] = _commentToken;

    // Eğer [isPending] ise sadece incelemede olan yorumları getir
    if (isPending) data['status'] = CommentStatus.pending.name;

    final response = await _dio.request(
      url: isPending
          ? KStrings.getComments(blogId: locator<HomeViewModel>().blogId)
          : commentUrl!,
      method: HttpMethod.get,
      data: data,
    );

    if (response == null) {
      if (!isLoadMore) setState(ViewState.idle);
      return;
    }

    if (isLoadMore) {
      // Kaydırdıkça yükleme yapmak için
      final newModel = CommentsModel.fromJson(response.data);
      commentsModel!.items.addAll(newModel.items);
      commentsModel!.pageToken = newModel.pageToken;
    } else {
      // Kaydırdıkça yükleme değilse ilk verileri al
      commentsModel = CommentsModel.fromJson(response.data);
    }
    if (!isLoadMore) setState(ViewState.idle);
  }

  // Kaydırdıkça yükleme methodu
  void loadMoreComments(String? commentUrl) async {
    const state = 'loadMore';
    if (commentsModel!.pageToken == null ||
        commentsModel!.pageToken == _commentToken ||
        isActiveState(state)) return;
    _commentToken = commentsModel!.pageToken;

    addState(state);
    await getComments(commentUrl: commentUrl, isLoadMore: true);
    deleteState(state);
  }

  // Yorumu, çekilen yorumlardan varsa id ile bul
  CommentModel? findCommentFromId(String? id) {
    if (id == null) return null;
    try {
      final item = commentsModel!.items.firstWhere((e) => e.id == id);
      return item;
    } catch (e) {
      return null;
    }
  }

  // Silinen, onaylanan, spam olarak işaretlenen yorumu state üzerinde güncelle
  void updateComment(CommentModel oldComment, CommentModel newComment) {
    final index = commentsModel!.items.indexOf(oldComment);
    commentsModel!.items.removeAt(index);
    commentsModel!.items.insert(index, newComment);
  }

  // Yorumu sil ve state güncelle
  Future<void> deleteComment(CommentModel comment) async {
    final response = await _dio.request(
        url: KStrings.deleteComment(comment), method: HttpMethod.delete);

    if (response == null) {
      deleteState(comment.id);
      return;
    }

    commentsModel!.items.remove(comment);
    deleteState(comment.id);
  }

  // Spam yorumu bildir
  Future<void> reportSpamComment(CommentModel comment) async {
    final response = await _dio.request(
        url: KStrings.spamComment(comment), method: HttpMethod.post);

    if (response == null) {
      deleteState(comment.id);
      return;
    }

    updateComment(comment, comment..status = CommentStatus.spam);
    deleteState(comment.id);
  }

  // İnceleme [isPending] bekleyen yorumu onayla
  Future<void> approveComment(CommentModel comment) async {
    final response = await _dio.request(
        url: KStrings.approveComment(comment), method: HttpMethod.post);

    if (response == null) {
      deleteState(comment.id);
      return;
    }

    updateComment(comment, comment..status = CommentStatus.live);
    deleteState(comment.id);
  }
}
