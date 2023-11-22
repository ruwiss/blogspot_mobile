import 'package:blogman/commons/services/ads/ads.dart';
import 'package:blogman/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../utils/colors.dart';

class NoItemWidget extends StatefulWidget {
  const NoItemWidget({super.key});

  @override
  State<NoItemWidget> createState() => _NoItemWidgetState();
}

class _NoItemWidgetState extends State<NoItemWidget> {
  BannerAd? _bannerAd;

  void _loadBannerAd() {
    BannerAdService(
      adSize: AdSize.mediumRectangle,
      adUnitId: KStrings.banner2,
      onLoaded: (ad) {
        setState(() => _bannerAd = ad);
      },
    ).loadAd();
  }

  @override
  void initState() {
    _loadBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_bannerAd != null) ...[
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
          const Spacer(),
        ],
        const Icon(
          Icons.calendar_view_day_sharp,
          size: 100,
          color: KColors.blueGray,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 50),
          child: Text(
            'noPost'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(.6),
            ),
          ),
        ),
        if (_bannerAd != null) const Spacer(),
      ],
    );
  }
}
