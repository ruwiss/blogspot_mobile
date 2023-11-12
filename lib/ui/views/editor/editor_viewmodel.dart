import 'package:blogman/models/post_model.dart';

import '../../../app/base/base_viewmodel.dart';

class EditorViewModel extends BaseViewModel {
  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  void setPostModel(PostModel postModel) {
    _postModel = postModel;
    notifyListeners();
  }
}
