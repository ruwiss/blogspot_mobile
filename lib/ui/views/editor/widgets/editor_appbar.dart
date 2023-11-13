import 'package:blogman/ui/views/editor/editor_viewmodel.dart';
import 'package:blogman/ui/views/editor/widgets/content_settings.dart';
import 'package:blogman/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  const EditorAppBar({super.key, required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<EditorAppBar> createState() => _EditorAppBarState();
}

class _EditorAppBarState extends State<EditorAppBar> {
  @override
  Widget build(BuildContext context) {
    final editorViewModel =
        Provider.of<EditorViewModel>(context, listen: false);
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: AppBar(
        backgroundColor: KColors.antiqueWhite,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: KColors.dark,
            size: 35,
          ),
        ),
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: KColors.dark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ContentSettings(editorContext: context),
              );
            },
            icon: const Icon(Icons.edit, color: KColors.dark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save, color: KColors.dark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send, color: KColors.dark),
          ),
        ],
      ),
    );
  }
}
