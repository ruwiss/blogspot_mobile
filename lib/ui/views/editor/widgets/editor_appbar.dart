import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final _tTitleFocus = FocusNode();
  final _tTitle = TextEditingController();

  bool _showInput = false;

  void _setInputVisibility(bool value) => setState(() => _showInput = value);

  @override
  Widget build(BuildContext context) {
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
        title: _showInput
            ? _inputFieldWidget()
            : Text(
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
              if (!_showInput) {
                _tTitle.text = widget.title;
                _setInputVisibility(true);
                _tTitleFocus.requestFocus();
              } else {
                _setInputVisibility(false);
              }
            },
            icon: Icon(_showInput ? Icons.check_circle : Icons.edit,
                color: _showInput ? KColors.blue : KColors.dark),
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

  Widget _inputFieldWidget() {
    const textStyle = TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: KColors.dark);

    const inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: KColors.blueGray),
    );
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: _tTitle,
          focusNode: _tTitleFocus,
          style: textStyle,
          cursorColor: KColors.blue,
          decoration: InputDecoration(
            hintText: 'enterTitle'.tr(),
            hintStyle: textStyle.copyWith(color: Colors.black38),
            isDense: true,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
          ),
        ),
        InkWell(
          onTap: () => _tTitle.clear(),
          child: const Icon(
            Icons.close,
            size: 18,
            color: KColors.dark,
          ),
        ),
      ],
    );
  }
}
