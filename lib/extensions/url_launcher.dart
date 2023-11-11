import 'package:url_launcher/url_launcher.dart';

extension UrlLauncher on Uri {
  Future<void> launch({bool appBrowser = false, bool browser = false}) async {
    if (await canLaunchUrl(this)) {
      launchUrl(
        this,
        mode: appBrowser
            ? LaunchMode.inAppBrowserView
            : browser
                ? LaunchMode.externalApplication
                : LaunchMode.inAppWebView,
      );
    }
  }
}
