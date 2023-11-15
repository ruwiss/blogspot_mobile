import 'package:flutter/services.dart';

import '../../../app/base/base_viewmodel.dart';
import '../../../app/locator.dart';
import '../../../commons/models/post_model.dart';
import '../../../commons/services/http_service.dart';

class PreviewViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  bool _contentVisible = false;
  bool get contentVisible => _contentVisible;

  // Devamını oku bölümünü gizle ve tüm içeriği göster
  void setContentVisible() {
    _contentVisible = true;
    notifyListeners();
  }

  // Tek bir içeriği getir
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

  // İçerik URL adresini cihaz panosuna kopyala
  void copyUrlToClipboard() =>
      Clipboard.setData(ClipboardData(text: postModel!.url));
}
