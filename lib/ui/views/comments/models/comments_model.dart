import '../../../../commons/models/author_model.dart';

enum CommentStatus { emptied, live, pending, spam, noStatus }

class CommentsModel {
  CommentsModel({this.pageToken, required this.items});
  String? pageToken;
  List<CommentModel> items;

  CommentsModel.fromJson(Map<String, dynamic> json)
      : pageToken = json['nextPageToken'],
        items = (json['items'] as List?)
                ?.map((e) => CommentModel.fromJson(e))
                .toList() ??
            [];
}

class CommentModel {
  CommentModel({
    required this.id,
    required this.status,
    required this.published,
    required this.updated,
    required this.inReplyTo,
    required this.postId,
    required this.blogId,
    required this.selfLink,
    required this.content,
    required this.author,
  });
  final String id;
  CommentStatus? status;
  final DateTime published;
  final DateTime updated;

  /// Reply comment id
  final String? inReplyTo;

  final String postId;

  final String blogId;

  final String selfLink;
  final String content;
  final AuthorModel author;

  CommentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        status = CommentStatus.values.singleWhere(
          (e) => e.name == json['status'],
          orElse: () => CommentStatus.noStatus,
        ),
        published = DateTime.parse(json['published']),
        updated = DateTime.parse(json['updated']),
        inReplyTo = json['inReplyTo']?['id'],
        postId = json['post']['id'],
        blogId = json['blog']['id'],
        selfLink = json['selfLink'],
        content = json['content'],
        author = AuthorModel.fromJson(json['author']);
}
