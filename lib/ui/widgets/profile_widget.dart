import 'package:blogman/commons/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../commons/models/author_model.dart';
import '../../utils/utils.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget(
      {super.key, required this.authorModel, required this.date});
  final AuthorModel authorModel;

  /// published, updated
  final (DateTime, DateTime) date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          child: Image.asset(
            authorModel.imageUrl ?? KImages.avatar,
            width: 35,
            height: 35,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          authorModel.displayName.formatUserName(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: KColors.blueGray,
          ),
        ),
        const Spacer(),

        // Post ne zaman yayınlandıysa tarih farkını hesapla ve göster
        Builder(
          builder: (context) {
            bool isUpdated = false;
            if (date.$1 != date.$2) isUpdated = true;
            return Text(
              (isUpdated ? date.$2 : date.$1)
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
