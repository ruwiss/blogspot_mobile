import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdService {
  BannerAdService({
    this.adUnitId = 'ca-app-pub-3940256099942544/6300978111',
    this.onLoaded,
    this.adSize,
  });
  final String adUnitId;
  final AdSize? adSize;
  final Function(BannerAd ad)? onLoaded;

  void loadAd() {
    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: adSize ?? AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          onLoaded?.call(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    ).load();
  }
}
