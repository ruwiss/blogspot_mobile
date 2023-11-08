class BlogModel {
  BlogModel({
    required this.id,
    required this.name,
    required this.url,
    required this.selfLink,
    required this.posts,
    required this.pages,
  });

  final String id;
  final String name;
  final String url;
  final String selfLink;
  final BlogPostsModel posts;
  final BlogPagesModel pages;

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      selfLink: json['selfLink'] as String,
      posts: BlogPostsModel.fromJson(json['posts']),
      pages: BlogPagesModel.fromJson(json['pages']),
    );
  }
}

class BlogPostsModel {
  BlogPostsModel({required this.totalItems, required this.selfLink});

  final int totalItems;
  final String selfLink;

  factory BlogPostsModel.fromJson(Map<String, dynamic> json) {
    return BlogPostsModel(
      totalItems: json['totalItems'] as int,
      selfLink: json['selfLink'] as String,
    );
  }
}

class BlogPagesModel {
  BlogPagesModel({required this.totalItems, required this.selfLink});

  final int totalItems;
  final String selfLink;

  factory BlogPagesModel.fromJson(Map<String, dynamic> json) {
    return BlogPagesModel(
      totalItems: json['totalItems'] as int,
      selfLink: json['selfLink'] as String,
    );
  }
}
