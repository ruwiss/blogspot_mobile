import 'package:blogman/commons/services/ads/ads.dart';
import 'package:blogman/utils/strings.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/core.dart';
import '../../../core/base/base_viewmodel.dart';
import '../../../commons/models/post_model.dart';

class PreviewViewModel extends BaseViewModel {
  final _dio = locator<HttpService>();
  BannerAd? bannerAd;

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

    loadBannerAd();

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

  void loadBannerAd() {
    BannerAdService(
      adUnitId: KStrings.banner1,
      adSize: AdSize.largeBanner,
      onLoaded: (ad) {
        bannerAd = ad;
        notifyListeners();
      },
    ).loadAd();
  }

  // İçerik URL adresini cihaz panosuna kopyala
  void copyUrlToClipboard() =>
      Clipboard.setData(ClipboardData(text: postModel!.url));
}
