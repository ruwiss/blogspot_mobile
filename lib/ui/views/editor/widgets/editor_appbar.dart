import 'package:blogman/enums/post_filter_enum.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/ui/views/editor/editor_viewmodel.dart';
import 'package:blogman/ui/views/editor/widgets/content_settings.dart';
import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  const EditorAppBar(
      {super.key, required this.model, required this.title, this.actions});
  final EditorViewModel model;
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<EditorAppBar> createState() => _EditorAppBarState();
}

class _EditorAppBarState extends State<EditorAppBar> {
  void _publishDraftContent() async {
    bool status = await widget.model.updateContent();
    if (status) {
      status = await widget.model.publishDraft();
      if (mounted) {
        if (status) {
          context.showInfo(text: 'contentPublished'.tr());
        } else {
          context.showError();
        }
      }
    }
  }

  Future<bool> _updateContent(bool isDraft) async {
    bool status = false;
    if (isDraft) {
      status = await widget.model.updateContent();
      if (mounted && status) context.showInfo(text: 'contentSaved'.tr());
    } else {
      status = await widget.model.updateContent();
      if (mounted && status) context.showInfo(text: 'contentPublished'.tr());
    }
    if (mounted && !status) context.showError();
    return status;
  }

  @override
  Widget build(BuildContext context) {
    bool isDraft = widget.model.postModel?.status == PostStatus.draft;
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
          widget.model.isActiveState('settings')
              ? _loadingWidget()
              : IconButton(
                  onPressed: () async {
                    final data = await showDialog(
                      context: context,
                      builder: (_) => ContentSettings(editorContext: context),
                    );
                    // içerik silindiyse sayfayı kapat
                    if (data != null && mounted && data['goBack']) {
                      context.pop();
                    }
                  },
                  icon: const Icon(Icons.edit, color: KColors.dark),
                ),
          if (isDraft)
            widget.model.isActiveState('sendContent')
                ? _loadingWidget()
                : IconButton(
                    onPressed: () => _updateContent(isDraft),
                    icon: const Icon(Icons.save, color: KColors.dark),
                  ),
          IconButton(
            onPressed: () =>
                isDraft ? _publishDraftContent() : _updateContent(isDraft),
            icon: widget.model.isActiveState('sendContent') && !isDraft
                ? _loadingWidget()
                : Icon(isDraft ? Icons.send : Icons.send_and_archive,
                    color: KColors.dark),
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: KColors.dark)),
      );
}
