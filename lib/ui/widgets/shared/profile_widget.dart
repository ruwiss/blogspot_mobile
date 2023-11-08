import 'package:blogman/extensions/datetime_formatter.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/images.dart';
import 'package:flutter/material.dart';

import '../../../models/post_model.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key, required this.postModel});
  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          child: Image.asset(
            postModel.author.imageUrl ?? KImages.avatar,
            width: 35,
            height: 35,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          postModel.author.displayName.formatUserName(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: KColors.blueGray,
          ),
        ),
        const Spacer(),
        Builder(
          builder: (context) {
            final DateTime published = postModel.published;
            final DateTime updated = postModel.updated;
            bool isUpdated = false;
            if (published != updated) isUpdated = true;
            return Text(
              (isUpdated ? updated : published)
                  .formatRelativeDateTime(isUpdated: isUpdated),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: KColors.blueGray,
              ),
            );
          },
        ),
      ],
    );
  }
}
