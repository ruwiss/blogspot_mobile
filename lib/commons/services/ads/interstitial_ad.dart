import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAdService({
    this.adUnitId = 'ca-app-pub-3940256099942544/1033173712',
    this.onLoaded,
  }) {
    loadAd();
  }
  final String adUnitId;
  final Function(InterstitialAd ad)? onLoaded;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          onLoaded?.call(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
