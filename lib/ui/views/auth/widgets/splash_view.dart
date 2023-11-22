import 'dart:async';

import 'package:blogman/utils/images.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _opacity = false;

  void _setAnimation() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Opacity true olduysa (dispose olduysa) state yenilenmesin
      if (!_opacity) setState(() => _opacity = true);
      timer.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    _setAnimation();
  }

  @override
  void dispose() {
    _opacity = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.orange,
        image: DecorationImage(
          image: AssetImage(KImages.splashBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: AnimatedScale(
        scale: _opacity ? 1.5 : 1,
        duration: const Duration(seconds: 3),
        child: Image.asset('assets/images/logo.png', width: 140),
      ),
    );
  }
}
