import 'package:blogman/extensions/context_extensions.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/extensions/url_launcher.dart';
import 'package:blogman/models/post_model.dart';
import 'package:blogman/ui/widgets/home/post_image.dart';
import 'package:blogman/ui/widgets/shared/profile_widget.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'preview_viewmodel.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({super.key, required this.contentUrl});
  final String contentUrl;

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  void _getContent() async {
    final status = await Provider.of<PreviewViewModel>(context, listen: false)
        .getSingleContent(widget.contentUrl);
    if (!status && mounted) context.showError();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getContent();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewViewModel>(
      builder: (context, model, child) => Scaffold(
        body: model.postModel == null
            ? const Center(
                child: CircularProgressIndicator(color: KColors.blue))
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: KColors.softWhite2,
                    leading: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close, color: KColors.dark),
                    ),
                    actions: _appBarActions(),
                    expandedHeight: 290,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 60),
                        child: PostImage(
                          postModel: model.postModel!,
                        ),
                      ),
                    ),
                  ),

                  // Profile Item
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ProfileWidget(
                        authorModel: model.postModel!.author,
                        date: (
                          model.postModel!.published,
                          model.postModel!.updated
                        ),
                      ),
                    ),
                  ),

                  // content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            model.postModel!.title,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.black.withOpacity(.85),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: !model.contentVisible ? 700 : null,
                            child: Html(
                              data: model.postModel!.content,
                              onLinkTap: (url, attributes, element) {
                                if (url!.isPicture()) {
                                  context.previewImage(url);
                                } else {
                                  Uri.parse(url).launch(browser: true);
                                }
                              },
                            ),
                          ),
                          _actionButtons(model)
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                ],
              ),
      ),
    );
  }

  Widget _actionButtons(PreviewViewModel model) {
    final PostReplies? replies = model.postModel!.replies;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        replies == null || replies.totalItems == '0'
            ? const Spacer()
            : TextButton(
                onPressed: () => context.pushNamed('comments',
                    queryParameters: {
                      'commentUrl': model.postModel!.replies!.selfLink
                    }),
                child: Row(
                  children: [
                    SvgPicture.asset(KImages.comment),
                    Text(
                      'comments'.tr(),
                      style: const TextStyle(
                          color: KColors.blueGray,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(${model.postModel!.replies?.totalItems})',
                      style: const TextStyle(
                          color: KColors.blueGray, fontSize: 14),
                    ),
                  ],
                ),
              ),
        if (!model.contentVisible)
          TextButton(
            onPressed: () => model.setContentVisible(),
            child: Text(
              'showMore'.tr(),
              style: TextStyle(
                  color: Colors.black.withOpacity(.9),
                  fontWeight: FontWeight.w700),
            ),
          )
      ],
    );
  }

  List<Widget> _appBarActions() {
    Widget divider() => const SizedBox(
          height: 15,
          child: VerticalDivider(color: KColors.blueGray, width: 15),
        );
    return [
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.share, color: KColors.blueGray),
      ),
      divider(),
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.remove_red_eye, color: KColors.blueGray),
      ),
      divider(),
      Text(
        'edit'.tr(),
        style: const TextStyle(
          color: KColors.blueGray,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(width: 15),
    ];
  }
}
