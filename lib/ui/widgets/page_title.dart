import 'package:blogman/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTitle extends StatelessWidget implements PreferredSizeWidget {
  const PageTitle({super.key, required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        backgroundColor: KColors.softWhite,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: KColors.dark,
            size: 35,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: KColors.dark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: actions,
      ),
    );
  }
}
