import 'package:blogman/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTitle extends StatelessWidget implements PreferredSizeWidget {
  const PageTitle({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.keyboard_arrow_left,
                color: KColors.dark,
                size: 35,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: KColors.dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 45),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
