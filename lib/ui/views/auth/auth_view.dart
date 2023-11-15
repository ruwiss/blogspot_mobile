import 'package:blogman/core/base/base_viewmodel.dart';
import 'package:blogman/commons/extensions/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../commons/services/services.dart';
import '../../../utils/utils.dart';
import 'auth_viewmodel.dart';
import 'widgets/auth_widgets.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _appSettings = locator<AppSettings>();
  final _authViewModel = locator<AuthViewModel>();

  void _authAndNavigate() async {
    // Kullanıcı giriş işlemi başarılıysa
    if (await _authViewModel.authUser()) {
      if (context.mounted) {
        // Daha önceden blog seçti mi kontrol et
        final selectedBlogId = _appSettings.getSelectedBlogId();
        // Daha önceden blog seçtiyse otomatik yönlendir
        if (selectedBlogId != null) {
          context.pushReplacementNamed('home',
              pathParameters: {'blogId': selectedBlogId});
        } else {
          // seçmediyse
          // Splash logoyu kapat
          _authViewModel.hideSplash();
          // BLog seçim görünümünü etkinleştir
          _showBlogSelectionDialog();
        }
      }
    } else {
      _authViewModel.hideSplash();
      if (context.mounted) context.showError();
    }
  }

  // Kullanıcı bloglarını çek
  void _showBlogSelectionDialog() async {
    final String? error = await _authViewModel.getUserBlogs();
    if (error != null && context.mounted) context.showError(error: error);
  }

  @override
  void initState() {
    // Eğer kullanıcı daha önce giriş yapmışsa
    _appSettings.isAuth().then((value) {
      // Splash logoyu kapat
      if (!value) _authViewModel.hideSplash();
      // Otomatik giriş yap ve yönlendir
      if (value && mounted) _authAndNavigate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, model, child) => Scaffold(
        body: model.splash
            ? const SplashView() // Splash Logo
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: KColors.orange,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(KImages.logo, width: 114),
                          _appNameWidget(),
                          _authInfoWidget(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: model.blogList == null ? 1 : 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: model.state == ViewState.busy &&
                              model.blogList == null
                          ? const CircularProgressIndicator(
                              color: KColors.orange)
                          : model.blogList == null
                              // OAuth Kullanıcı Giriş Görünümü
                              ? _authButtons(context, model)
                              // Kullanıcı Blog Seçim Görünümü
                              : BlogSelectWidget(
                                  model: model,
                                  onError: (error) =>
                                      context.showError(error: error)),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _authButtons(BuildContext context, AuthViewModel model) {
    return Column(
      key: const Key('authButtons'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        AuthButton(
          icon: Image.asset(KImages.google),
          bgColor: KColors.blue,
          text: 'googleAuth'.tr(),
          onTap: () => _authAndNavigate(),
        ),
        const SizedBox(height: 30),
        AuthButton(
          icon: SvgPicture.asset(
            KImages.blogger,
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
          ),
          bgColor: KColors.orange,
          text: 'createBlog'.tr(),
          onTap: () =>
              Uri.parse(KStrings.createBlogUrl).launch(appBrowser: true),
        ),
        const Spacer(),
        _privacyPolicy()
      ],
    );
  }

  TextButton _privacyPolicy() {
    return TextButton(
      onPressed: () => Uri.parse(KStrings.privacyPolicyUrl).launch(),
      child: const Text(
        'privacyPolicy',
        style: TextStyle(
          color: KColors.dark,
          fontSize: 14,
        ),
      ).tr(),
    );
  }

  Padding _authInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'authInfo',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade100),
      ).tr(),
    );
  }

  Padding _appNameWidget() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 25, top: 30),
      child: Text(
        KStrings.appName,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
