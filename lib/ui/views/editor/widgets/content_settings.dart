import 'package:blogman/enums/post_filter_enum.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/ui/views/editor/editor_viewmodel.dart';
import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContentSettings extends StatefulWidget {
  const ContentSettings({super.key, required this.editorContext});
  final BuildContext editorContext;

  @override
  State<ContentSettings> createState() => _ContentSettingsState();
}

class _ContentSettingsState extends State<ContentSettings> {
  final _tTitle = TextEditingController();
  final _tLabel = TextEditingController();

  @override
  void initState() {
    final editorViewModel = Provider.of<EditorViewModel>(widget.editorContext);
    _tTitle.text = editorViewModel.postModel!.title;
    _tLabel.text = editorViewModel.postModel!.labels.join(', ');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final editorViewModel = Provider.of<EditorViewModel>(widget.editorContext);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'contentSettings'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KColors.dark,
                  ),
                ),
                editorViewModel.isActiveState('deleteContent')
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: KColors.orange))
                    : IconButton(
                        onPressed: () async {
                          setState(() {
                            editorViewModel.addState('deleteContent');
                          });
                          final status = await editorViewModel.deleteContent();
                          setState(() {
                            editorViewModel.deleteState('deleteContent');
                          });
                          if (!status) {
                            if (mounted) context.showError();
                          } else {
                            if (mounted) context.pop({'goBack': true});
                          }
                        },
                        icon: const Icon(
                          Icons.delete_sweep,
                          size: 25,
                          color: KColors.orange,
                        ),
                      )
              ],
            ),
            const SizedBox(height: 20),
            _inputWidget(
              controller: _tTitle,
              hint: 'contentTitle'.tr(),
              onChanged: (value) => editorViewModel.postModel!.title = value,
            ),
            _inputWidget(
              controller: _tLabel,
              hint: 'contentLabels'.tr(),
              onChanged: (value) => editorViewModel.postModel!.labels =
                  value.split(',').map((e) => e.trim()).toList(),
            ),
            _inputWidget(
              hint: 'contentComments'.tr(),
              onPressed: () {
                editorViewModel.setReaderComments();
                setState(() {});
              },
              switchEnabled: editorViewModel.postModel!.readerComments,
            ),
            const SizedBox(height: 16),
            if (editorViewModel.postModel!.status == PostStatus.live)
              _settingButton(
                text: 'convertToDraft'.tr(),
                onTap: editorViewModel.convertToDraft,
              ),
            if (editorViewModel.postModel!.status == PostStatus.draft)
              _settingButton(
                text: 'schedulePost'.tr(),
                onTap: () {},
              ),
            _settingButton(text: 'saveSettings'.tr())
          ],
        ),
      ),
    );
  }

  Widget _settingButton({required String text, VoidCallback? onTap}) {
    final borderRadius = BorderRadius.circular(4);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: KColors.whiteSmoke,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () {
            context.pop();
            onTap?.call();
          },
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputWidget(
      {TextEditingController? controller,
      required String hint,
      bool? switchEnabled,
      Function()? onPressed,
      Function(String value)? onChanged}) {
    final bool isSwitch = switchEnabled != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextFormField(
            controller: controller,
            onTap: () {
              if (isSwitch) onPressed?.call();
            },
            onChanged: onChanged,
            readOnly: isSwitch,
            style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(.6)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none),
              enabled: true,
              isDense: true,
              filled: true,
              fillColor: KColors.whiteSmoke,
              hintText: hint,
            ),
          ),
          if (isSwitch)
            Positioned(
              right: 10,
              child: Text(
                switchEnabled ? 'on'.tr() : 'off'.tr(),
                style: TextStyle(
                  color: switchEnabled ? KColors.orange : KColors.blueGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
        ],
      ),
    );
  }
}
