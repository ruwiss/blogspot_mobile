import 'package:blogman/utils/images.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _opacity = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = true;
      });
    });
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
