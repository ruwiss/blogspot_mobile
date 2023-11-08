import 'package:url_launcher/url_launcher.dart';

extension UrlLauncher on Uri {
  Future<void> launch({bool browser = false}) async {
    if (await canLaunchUrl(this)) {
      launchUrl(
        this,
        mode:
        browser ? LaunchMode.inAppBrowserView : LaunchMode.inAppWebView,
      );
    }
  }
}
