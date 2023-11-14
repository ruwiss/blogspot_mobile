import 'package:blogman/services/http_service.dart';
import 'package:blogman/models/post_model.dart';
import 'package:flutter/services.dart';

import '../../../app/base/base_viewmodel.dart';
import '../../../app/locator.dart';

class PreviewViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  bool _contentVisible = false;
  bool get contentVisible => _contentVisible;

  void setContentVisible() {
    _contentVisible = true;
    notifyListeners();
  }

  Future<bool> getSingleContent(String contentUrl) async {
    setState(ViewState.busy);

    final response = await _dio.request(
        url: contentUrl,
        method: HttpMethod.get,
        data: {"view": "ADMIN", "fetchImages": true});

    if (response == null) {
      setState(ViewState.idle);
      return false;
    }

    _postModel = PostModel.fromJson(response.data);

    setState(ViewState.idle);
    return true;
  }

  void copyUrlToClipboard() =>
      Clipboard.setData(ClipboardData(text: postModel!.url));
}
