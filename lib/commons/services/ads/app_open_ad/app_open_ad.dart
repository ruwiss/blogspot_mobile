import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class AppOpenAdService {
  AppOpenAdService({this.adUnitId = 'ca-app-pub-3940256099942544/3419835294'});
  final String adUnitId;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;


  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          log('AppOpenAd yükleme sorunu: $error');
        },
      ),
    );
  }

  bool get isAdAvailable => _appOpenAd != null;

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      log('Reklam bulunamadığı için yükleniyor.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      log('Reklam mevcut ve gösteriliyor.');
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        log('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        log('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}