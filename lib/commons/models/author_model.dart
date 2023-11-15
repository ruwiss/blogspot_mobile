class AuthorModel {
  AuthorModel({
    this.id,
    required this.displayName,
    this.url,
    required this.imageUrl,
  });
  final String? id;
  final String displayName;
  final String? url;
  final String? imageUrl;

  AuthorModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        displayName = json['displayName'] as String,
        url = json['url'] as String?,
        imageUrl = json['imageUrl'] as String?;

  Map<String, dynamic> toJson() =>
      {'id': id, 'displayName': displayName, 'url': url, 'imageUrl': imageUrl};
}
