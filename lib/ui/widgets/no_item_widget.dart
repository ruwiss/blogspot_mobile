import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class NoItemWidget extends StatelessWidget {
  const NoItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.calendar_view_day_sharp,
          size: 100,
          color: KColors.blueGray,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 50),
          child: Text(
            'noPost'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(.6),
            ),
          ),
        ),
      ],
    );
  }
}
