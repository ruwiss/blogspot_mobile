import 'package:blogman/models/post_model.dart';
import 'package:blogman/ui/views/editor/widgets/editor_appbar.dart';
import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'editor_viewmodel.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.postModel});
  final PostModel postModel;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final QuillEditorController _editorController = QuillEditorController();

  final _tImageInputFocus = FocusNode();
  final _tImageInput = TextEditingController();
  bool _showImageInput = false;

  void _setImageInputVisibility(bool value) {
    setState(() => _showImageInput = value);
    if (value) {
      _tImageInputFocus.requestFocus();
    } else {
      _tImageInput.clear();
    }
  }

  void _setInitialValue() {
    Provider.of<EditorViewModel>(context, listen: false)
        .setPostModel(widget.postModel);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialValue();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, model, child) => Container(
        color: KColors.whiteSmoke,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: KColors.whiteSmoke,
            appBar: EditorAppBar(
                title: model.postModel?.title ?? widget.postModel.title),
            body: model.postModel == null
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ToolBar(
                        toolBarColor: KColors.whiteSmoke,
                        activeIconColor: KColors.orange.withOpacity(.5),
                        padding: const EdgeInsets.all(8),
                        iconSize: 20,
                        controller: _editorController,
                        iconColor: KColors.dark,
                        alignment: WrapAlignment.center,
                        toolBarConfig: model.customToolBarList,
                        customButtons: [
                          InkWell(
                              onTap: () => _setImageInputVisibility(true),
                              child: const Icon(Icons.image)),
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              'HTML\nEDITOR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      if (_showImageInput) _imageInputWidget(),
                      Flexible(
                        child: QuillHtmlEditor(
                          text: model.postModel!.content,
                          hintText: "   ${tr('startWriting')}",
                          controller: _editorController,
                          isEnabled: true,
                          minHeight: 300,
                          textStyle: const TextStyle(
                              fontSize: 15,
                              color: KColors.dark,
                              fontFamily: 'Nunito Sans'),
                          hintTextStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black38,
                              fontFamily: 'Nunito Sans'),
                          hintTextAlign: TextAlign.start,
                          padding:
                              const EdgeInsets.only(left: 10, top: 5, right: 5),
                          onTextChanged: (t) =>
                              model.setContentLength(t.length),
                          hintTextPadding: EdgeInsets.zero,
                          backgroundColor: KColors.whiteSmoke,
                          loadingBuilder: (context) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 0.4),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "${tr('length')} ${model.contentLength} ",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Container _imageInputWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Flexible(
        child: TextField(
          controller: _tImageInput,
          focusNode: _tImageInputFocus,
          style: const TextStyle(color: KColors.dark),
          decoration: InputDecoration(
            focusedBorder: const UnderlineInputBorder(),
            hintText: 'imgUrl'.tr(),
            isDense: true,
            suffix: SizedBox(
              width: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      await _editorController.embedImage(_tImageInput.text);
                      _setImageInputVisibility(false);
                    },
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: KColors.blue,
                    ),
                  ),
                  InkWell(
                    onTap: () => _setImageInputVisibility(false),
                    child: const Icon(Icons.cancel_outlined),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
