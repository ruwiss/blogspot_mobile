import 'package:blogman/extensions/datetime_formatter.dart';
import 'package:blogman/models/post_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../enums/post_filter_enum.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.postModel});
  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    final bool scheduled = postModel.status == PostStatus.scheduled;
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
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
        ),

        // Zamanlanmış postlar için vinyet efekti ve süresi.
        if (postModel.status != null &&
            postModel.status == PostStatus.scheduled)
          ..._scheduledView()
      ],
    );
  }

  List<Widget> _scheduledView() => [
        Positioned(
          top: -100,
          bottom: -100,
          left: -100,
          right: -100,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape
                  .circle, // İsterseniz bu şekli istediğiniz gibi değiştirebilirsiniz
              gradient: RadialGradient(
                center: Alignment
                    .center, // Gradientin merkezi (burada container'ın merkezi)
                radius: 1, // Gradientin dışarı doğru yayılma oranı
                colors: [
                  Colors.black26,
                  Colors.black87,
                  Colors.black,
                ], // Gradientin renkleri
              ),
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'scheduled'.tr().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              postModel.published.formatAsDayMonthYear(),
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
                fontSize: 15,
              ),
            )
          ],
        )
      ];
}
