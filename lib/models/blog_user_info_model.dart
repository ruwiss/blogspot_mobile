class BlogUserInfoModel {
  BlogUserInfoModel(
      {required this.photosAlbumKey, required this.hasAdminAccess});
  final String? photosAlbumKey;
  final bool hasAdminAccess;

  BlogUserInfoModel.fromJson(Map<String, dynamic> json)
      : photosAlbumKey = json['photosAlbumKey'],
        hasAdminAccess = json['hasAdminAccess'];
}
