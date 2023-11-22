import 'dart:developer';
import 'package:blogman/commons/services/ads/app_open_ad/app_open_ad.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppLifecycleReactor {
  AppLifecycleReactor({required this.appOpenAdManager});
  final AppOpenAdService appOpenAdManager;

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    log("App State Changed: ${appState.name}");
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}