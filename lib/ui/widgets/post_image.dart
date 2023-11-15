import 'package:blogman/commons/extensions/datetime_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../commons/enums/post_filter_enum.dart';
import '../../commons/models/post_model.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';

class PostImage extends StatelessWidget {
  const PostImage(
      {super.key,
      this.postModel,
      this.imageUrl,
      this.hideScheduledEffect = false});
  final PostModel? postModel;
  final String? imageUrl;
  final bool hideScheduledEffect;

  @override
  Widget build(BuildContext context) {
    final bool scheduled = postModel?.status == PostStatus.scheduled;
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: postModel?.image != null || imageUrl != null
              ? 16 / 9
              : scheduled
                  ? 16 / 3
                  : 16 / .2,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            child: imageUrl != null || postModel?.image != null
                // Post model veya image url olarak 2 farklı şekilde burası
                // çalışacak. Eğer postModel üzerinde resim yoksa image url
                // devreye girecek. Eğer o da resim değilse gizle
                ? Hero(
                    tag: postModel?.image ?? imageUrl!,
                    child: FadeInImage.assetNetwork(
                      placeholder: KImages.placeholder,
                      image: postModel?.image ?? imageUrl!,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  )
                : Container(
                    color: scheduled
                        ? Colors.black.withOpacity(.2)
                        : KColors.blueGray.withOpacity(.8),
                  ),
          ),
        ),

        // Zamanlanmış postlar için vinyet efekti ve süresi.
        if (postModel?.status != null &&
            postModel?.status == PostStatus.scheduled &&
            !hideScheduledEffect)
          ..._scheduledView()
      ],
    );
  }

  List<Widget> _scheduledView() => [
        // Gradient efekti
        Positioned(
          top: -100,
          bottom: -100,
          left: -100,
          right: -100,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1,
                colors: [
                  Colors.black26,
                  Colors.black.withOpacity(.7),
                  Colors.black,
                ], // Gradientin renkleri
              ),
            ),
          ),
        ),
        // Gradient efekti üzerine zamanlanmış tarihi metin olarak göster
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              postModel!.published.formatAsDayMonthYear(),
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
                fontSize: 15,
              ),
            )
          ],
        )
      ];
}
