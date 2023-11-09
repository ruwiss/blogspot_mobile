import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/profile/profile_viewmodel.dart';
import 'package:blogman/ui/widgets/profile/profile_container.dart';
import 'package:blogman/ui/widgets/profile/profile_user_info.dart';
import 'package:blogman/ui/widgets/shared/page_title.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locator<ProfileViewModel>().getBlogsIfNotAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageTitle(title: 'yourProfile'.tr()),
      body: Consumer<AuthViewModel>(
        builder: (context, model, child) => Column(
          children: [
            ProfileUserInfo(user: model.user!),
            const SizedBox(height: 10),
            ProfileContainer(
                title: 'chooseBlog'.tr(),
                titleBgColor: KColors.bisqueColor,
                children: [
                  if (model.blogList == null) ...[
                    if (model.state == ViewState.busy)
                      Text('waiting'.tr(), textAlign: TextAlign.center),
                    if (model.state == ViewState.idle)
                      Text('unknownError'.tr(), textAlign: TextAlign.center),
                  ],
                  if (model.blogList != null)
                    ...List.generate(model.blogList!.length, (index) {
                      final BlogModel blog = model.blogList![index];
                      return ProfileContainerTile(
                        onTap: () {
                          locator<ProfileViewModel>().changeUserBlog(blog);
                          context.pop();
                        },
                        text: blog.name,
                        suffix: SvgPicture.asset(
                            model.selectedBlog?.id == blog.id
                                ? KImages.check
                                : KImages.checkOutline),
                      );
                    }),
                ]),
            ProfileContainer(
              title: 'statistics'.tr(),
              titleBgColor: KColors.blueSea,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
