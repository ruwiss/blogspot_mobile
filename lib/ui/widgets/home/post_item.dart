import 'package:blogman/enums/post_filter_enum.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/post_model.dart';
import '../shared/profile_widget.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.postModel});
  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    final bool commented =
        postModel.replies != null && postModel.replies!.totalItems != '0';
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 11.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                offset: const Offset(2, 2),
                blurRadius: 14,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              _imageWidget(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileWidget(postModel: postModel),
                    const SizedBox(height: 20),
                    Text(
                      postModel.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(.85),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5,
                          bottom: commented ? 10 : 5,
                          right: commented ? 40 : 0),
                      child: Text(
                        postModel.content.formatHtml(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(.40),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (commented)
          Positioned(
            bottom: 19,
            right: 35,
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
          )
      ],
    );
  }

  Widget _imageWidget() {
    bool scheduled = postModel.status == PostStatus.scheduled;
    return AspectRatio(
      aspectRatio: postModel.image != null
          ? 16 / 9
          : scheduled
              ? 16 / 3
              : 16 / .2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
        ),
        child: postModel.image != null
            ? FadeInImage.assetNetwork(
                placeholder: KImages.placeholder,
                image: postModel.image!,
                fit: BoxFit.cover,
              )
            : Container(
                color: scheduled
                    ? Colors.black.withOpacity(.2)
                    : KColors.blueGray.withOpacity(.8),
              ),
      ),
    );
  }
}
