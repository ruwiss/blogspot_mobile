import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/auth/models/blog_model.dart';
import 'package:blogman/ui/views/profile/profile_viewmodel.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../widgets/page_title.dart';
import 'widgets/profile_container.dart';
import 'widgets/profile_user_info.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Profil verilerini ekran açılınca getir
      locator<ProfileViewModel>().getProfileValues();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageTitle(
        title: 'yourProfile'.tr(),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, model, child) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileUserInfo(user: model.user!),
              const SizedBox(height: 10),

              // Blog seçim ekranı
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

              // Blog istatistikleri
              Consumer<ProfileViewModel>(
                builder: (context, value, child) => ProfileContainer(
                  title: 'statistics'.tr(),
                  titleBgColor: KColors.blueSea,
                  children: [
                    if (value.statistics == null)
                      Text('waiting'.tr(), textAlign: TextAlign.center),
                    if (value.statistics != null) ...[
                      ProfileContainerTile(
                        text: 'Week',
                        suffix: _statisticsViews(value.statistics!.days7),
                      ),
                      ProfileContainerTile(
                        text: 'Month',
                        suffix: _statisticsViews(value.statistics!.days30),
                      ),
                      ProfileContainerTile(
                        text: 'All',
                        suffix: _statisticsViews(value.statistics!.all),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ProfileContainerTile(
                              text:
                                  '${locator<AuthViewModel>().selectedBlog!.posts.totalItems} Posts'),
                          ProfileContainerTile(
                              text:
                                  '${locator<AuthViewModel>().selectedBlog!.pages.totalItems} Pages')
                        ],
                      )
                    ]
                  ],
                ),
              ),
              _commentsButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // İnceleme bekleyen yorumları göster butonu
  Widget _commentsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 35),
      child: InkWell(
        onTap: () => context.pushReplacementNamed('comments',
            queryParameters: {"isPending": "true"}),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: KColors.grayButton,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'pendingComments'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black.withOpacity(.7),
            ),
          ),
        ),
      ),
    );
  }

  Row _statisticsViews(String value) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.black.withOpacity(.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.remove_red_eye,
          color: KColors.blueGray,
          size: 20,
        )
      ],
    );
  }
}
