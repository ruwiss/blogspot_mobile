import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/extensions/url_launcher.dart';
import 'package:blogman/services/shared_preferences/settings.dart';
import 'package:blogman/ui/widgets/auth/auth_button.dart';
import 'package:blogman/ui/widgets/auth/blog_select_widget.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:blogman/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/locator.dart';
import 'auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _appSettings = locator<AppSettings>();
  final _authViewModel = locator<AuthViewModel>();

  void _authAndNavigate() async {
    if (await _authViewModel.authUser()) {
      if (context.mounted) {
        final selectedBlogId = _appSettings.getSelectedBlogId();
        if (selectedBlogId != null) {
          context.pushReplacementNamed('home',
              pathParameters: {'blogId': selectedBlogId});
        } else {
          _showBlogSelectionDialog();
        }
      }
    } else {
      if (context.mounted) context.showError();
    }
  }

  void _showBlogSelectionDialog() async {
    final String? error = await _authViewModel.getUserBlogs();
    if (error != null && context.mounted) context.showError(error: error);
  }

  @override
  void initState() {
    //locator<AuthViewModel>().signOut();
    _appSettings.isAuth().then((value) {
      if (value && mounted) _authAndNavigate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, model, child) => Scaffold(
        body: Column(
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
                child: model.state == ViewState.busy && model.blogList == null
                    ? const CircularProgressIndicator(color: KColors.orange)
                    : model.blogList == null
                        ? _authButtons(context, model)
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
          onTap: () => Uri.parse(KStrings.createBlogUrl).launch(browser: true),
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
