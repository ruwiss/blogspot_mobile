import 'package:blogman/enums/post_filter_enum.dart';

import 'author_model.dart';

class PostListModel {
  PostListModel({this.nextPageToken, required this.items});

  String? nextPageToken;
  final List<PostModel> items;

  factory PostListModel.fromJson(Map<String, dynamic> json) {
    final List<PostModel> items = (json['items'] as List<dynamic>?)
            ?.map((e) => PostModel.fromJson(e))
            .toList() ??
        [];

    return PostListModel(nextPageToken: json['nextPageToken'], items: items);
  }
}

class PostModel {
  PostModel({
    required this.blogId,
    required this.id,
    required this.published,
    required this.updated,
    required this.url,
    required this.selfLink,
    required this.title,
    required this.content,
    required this.author,
    this.replies,
    required this.labels,
    this.image,
    this.status,
    required this.readerComments,
  });

  final String id;
  final String blogId;
  final DateTime published;
  final DateTime updated;
  final String url;
  final String selfLink;
  String title;
  String content;
  final AuthorModel author;
  final PostReplies? replies;
  List<String> labels;
  final String? image;
  PostStatus? status;
  bool readerComments;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      blogId: json['blog']['id'],
      published: DateTime.parse(json['published']),
      updated: DateTime.parse(json['updated']),
      url: json['url'] as String,
      selfLink: json['selfLink'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: AuthorModel.fromJson(json['author']),
      readerComments: json['readerComments'] == 'ALLOW',
      replies: json['replies'] != null
          ? PostReplies.fromJson(json['replies'])
          : null,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      image: (json['images'] as List<dynamic>?)?.isNotEmpty ?? false
          ? json['images'][0]['url'] as String
          : null,
      status: !json.containsKey('status')
          ? null
          : PostStatus.values.singleWhere(
              (e) => e.name == (json['status'] as String).toLowerCase()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'blog': {'id': blogId},
        'url': url,
        'selfLink': selfLink,
        'title': title,
        'content': content,
        'labels': labels,
        'status': status?.name,
        'readerComments': readerComments ? 'ALLOW' : 'DONT_ALLOW_HIDE_EXISTING',
      };
}

class PostReplies {
  PostReplies({required this.totalItems, required this.selfLink});

  final String totalItems;
  final String selfLink;

  factory PostReplies.fromJson(Map<String, dynamic> json) {
    return PostReplies(
      totalItems: json['totalItems'] as String,
      selfLink: json['selfLink'] as String,
    );
  }

  Map<String, dynamic> toJson() =>
      {'totalItems': totalItems, 'selfLink': selfLink};
}
