import 'package:blogman/core/core.dart';
import 'package:blogman/core/base/base_viewmodel.dart';
import 'package:blogman/commons/extensions/extensions.dart';
import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'editor_viewmodel.dart';
import 'widgets/editor_widgets.dart';
import '../../../commons/models/models.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.postModel});
  final PostModel postModel;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _tImageInputFocus = FocusNode();
  final _tImageInput = TextEditingController();

  bool _showImageInput = false;

  DateTime? currentBackPressTime;

  void _setImageInputVisibility(bool value) {
    setState(() => _showImageInput = value);
    if (value) {
      _tImageInputFocus.requestFocus();
    } else {
      _tImageInput.clear();
    }
  }

  Future<bool> _onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      context.showInfo(text: 'editorExitMsg'.tr());
      return Future.value(false);
    }
    return Future.value(true);
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (await _onWillPop() && context.mounted) context.pop();
      },
      child: Consumer<EditorViewModel>(
        builder: (context, model, child) => Container(
          color: KColors.whiteSmoke,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: KColors.whiteSmoke,
              appBar: EditorAppBar(
                  onBackPressed: () async {
                    if (await _onWillPop() && mounted) context.pop();
                  },
                  model: model,
                  title: model.postModel?.title ?? widget.postModel.title),
              body: model.postModel == null || model.state == ViewState.busy
                  ? const Center(
                      child: CircularProgressIndicator(color: KColors.blue),
                    )
                  : model.htmlEditorView
                      ? _htmlEditorView(model)
                      : _textEditorView(model),
            ),
          ),
        ),
      ),
    );
  }

  Column _textEditorView(EditorViewModel model) {
    return Column(
      children: [
        ToolBar(
          toolBarColor: KColors.whiteSmoke,
          activeIconColor: KColors.orange.withOpacity(.5),
          padding: const EdgeInsets.all(8),
          iconSize: 20,
          controller: model.editorController,
          iconColor: KColors.dark,
          alignment: WrapAlignment.center,
          toolBarConfig: model.customToolBarList,
          customButtons: [
            InkWell(
                onTap: () => _setImageInputVisibility(true),
                child: const Icon(Icons.image)),
            InkWell(
              onTap: () => model.setHtmlEditorView(true),
              child: const Text(
                'HTML\nEDITOR',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (_showImageInput) _imageInputWidget(model),
        Flexible(
          child: QuillHtmlEditor(
            text: model.postModel!.content,
            hintText: "   ${tr('startWriting')}",
            controller: model.editorController,
            isEnabled: true,
            minHeight: 300,
            textStyle: const TextStyle(
                fontSize: 15, color: KColors.dark, fontFamily: 'Nunito Sans'),
            hintTextStyle: const TextStyle(
                fontSize: 15, color: Colors.black38, fontFamily: 'Nunito Sans'),
            hintTextAlign: TextAlign.start,
            padding: const EdgeInsets.only(left: 10, top: 5, right: 5),
            onTextChanged: (t) => model.setContentLength(t.length),
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
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        )
      ],
    );
  }

  Container _imageInputWidget(EditorViewModel model) {
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
                      await model.editorController
                          .embedImage(_tImageInput.text);
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

  Widget _htmlEditorView(EditorViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(model.htmlToolbar.length, (index) {
                final tag = model.htmlToolbar[index];
                return Row(
                  children: [
                    if (index == 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => model.setHtmlEditorView(false),
                          child: const Text(
                            'TEXT\nEDITOR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => model.addHtmlTag(tag: tag),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            color: KColors.antiqueWhite,
                            borderRadius: BorderRadius.circular(3)),
                        child: Text(
                          tag.length < 3 ? ' $tag ' : tag,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: model.htmlController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: KColors.dark, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'startWritingHtml'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
