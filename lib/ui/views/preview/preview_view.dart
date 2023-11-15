import 'package:blogman/extensions/context_extensions.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/extensions/url_launcher.dart';
import 'package:blogman/models/post_model.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/post_image.dart';
import '../../widgets/profile_widget.dart';
import 'preview_viewmodel.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({super.key, required this.contentUrl, this.previewImgUrl});
  final String contentUrl;
  final String? previewImgUrl;

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  // İçeriği ekran açılınca çağır
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
      builder: (context, model, child) => Container(
        color: KColors.softWhite2,
        child: SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: KColors.softWhite2,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: KColors.dark),
                  ),
                  actions: _appBarActions(model),
                  expandedHeight: (widget.previewImgUrl == null ||
                              widget.previewImgUrl!.isEmpty) &&
                          model.postModel?.image == null
                      ? 80
                      : 290,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 60),
                      child: PostImage(
                        postModel: model.postModel,
                        imageUrl: widget.previewImgUrl,
                        // Hero animasyonunun görünmesi için bu ekranda
                        // Zamanlanmış içerikler için olan efekti gizle
                        hideScheduledEffect: true,
                      ),
                    ),
                  ),
                ),

                if (model.postModel == null)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(color: KColors.blue),
                      ),
                    ),
                  ),

                if (model.postModel != null) ...[
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
                ]

                // Action Buttons
              ],
            ),
          ),
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

        // Devamını göster butonu
        if (!model.contentVisible && model.postModel!.content.length > 1000)
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

  List<Widget> _appBarActions(PreviewViewModel model) {
    Widget divider() => const SizedBox(
          height: 15,
          child: VerticalDivider(color: KColors.blueGray, width: 15),
        );
    return [
      // Paylaş butonu
      GestureDetector(
        onTap: () {
          model.copyUrlToClipboard();
          context.showInfo(text: tr('copied'));
        },
        child: const Icon(Icons.share, color: KColors.blueGray),
      ),

      divider(),

      // İçeriği tarayıcıda aç butonu
      GestureDetector(
        onTap: () {
          if (model.postModel != null) {
            Uri.parse(model.postModel!.url).launch(browser: true);
          }
        },
        child: const Icon(Icons.remove_red_eye, color: KColors.blueGray),
      ),

      divider(),

      // Editör sayfasına git butonu
      GestureDetector(
        onTap: () {
          if (model.postModel != null) {
            context.pushReplacementNamed('editor', extra: model.postModel);
          }
        },
        child: Text(
          'edit'.tr(),
          style: const TextStyle(
            color: KColors.blueGray,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      const SizedBox(width: 15),
    ];
  }
}
