import 'package:blogman/models/author_model.dart';

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
  final String status;
  final DateTime published;
  final DateTime updated;

  /// Reply id
  final String? inReplyTo;

  final String postId;

  final String blogId;

  final String selfLink;
  final String content;
  final AuthorModel author;

  CommentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        status = json['status'] as String,
        published = DateTime.parse(json['published']),
        updated = DateTime.parse(json['updated']),
        inReplyTo = json['inReplyTo']?['id'],
        postId = json['post'],
        blogId = json['blog'],
        selfLink = json['selfLink'],
        content = json['content'],
        author = AuthorModel.fromJson(json['author']);
}
