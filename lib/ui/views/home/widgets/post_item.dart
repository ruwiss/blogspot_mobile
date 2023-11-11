import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/post_model.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/post_image.dart';


class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.postModel});
  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    final bool commented =
        postModel.replies != null && postModel.replies!.totalItems != '0';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 11.5),
      child: Material(
        color: Colors.white,
        elevation: 1,
        type: MaterialType.card,
        shadowColor: Colors.black.withOpacity(.7),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => context.pushNamed('preview',
              queryParameters: {'contentUrl': postModel.selfLink}),
          child: Stack(
            children: [
              Column(
                children: [
                  PostImage(postModel: postModel),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileWidget(
                            authorModel: postModel.author,
                            date: (postModel.published, postModel.updated)),
                        const SizedBox(height: 20),
                        _titleWidget(),
                        _contentPreviewWidget(commented),
                      ],
                    ),
                  )
                ],
              ),
              if (commented) _commentPreviewWidget()
            ],
          ),
        ),
      ),
    );
  }

  Positioned _commentPreviewWidget() {
    return Positioned(
      bottom: 8,
      right: 16,
      child: Row(
        children: [
          SvgPicture.asset(KImages.comment),
          Text(
            postModel.replies!.totalItems,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: KColors.blueGray),
          ),
        ],
      ),
    );
  }

  Padding _contentPreviewWidget(bool commented) {
    return Padding(
      padding: EdgeInsets.only(
          top: 5, bottom: commented ? 10 : 5, right: commented ? 40 : 0),
      child: Text(
        postModel.content.formatHtml(),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          fontSize: 13,
          color: Colors.black.withOpacity(.40),
        ),
      ),
    );
  }

  Text _titleWidget() {
    return Text(
      postModel.title,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: Colors.black.withOpacity(.85),
      ),
    );
  }
}
