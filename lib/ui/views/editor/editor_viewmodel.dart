import 'package:blogman/app/locator.dart';
import 'package:blogman/enums/post_filter_enum.dart';
import 'package:blogman/models/post_model.dart';
import 'package:blogman/services/http_service.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

import '../../../app/base/base_viewmodel.dart';

class EditorViewModel extends BaseViewModel {
  final editorController = QuillEditorController();
  final htmlController = TextEditingController();

  final _dio = locator<HttpService>();

  bool htmlEditorView = false;
  final List<String> htmlToolbar = [
    "🏷️",
    "html",
    "head",
    "title",
    "p",
    "b",
    "i",
    "h1",
    "h2",
    "div",
    "br",
    "a",
    "img",
    "code",
    "hr",
    "blockquote",
    "ol",
    "ul",
    "li"
  ];

  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  int contentLength = 0;
  void setContentLength(int value) {
    contentLength = value;
    notifyListeners();
  }

  final customToolBarList = [
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.align,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.addTable,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
  ];

  void setPostModel(PostModel postModel) {
    _postModel = postModel;
    contentLength = postModel.content.length;
    notifyListeners();
  }

  void setHtmlEditorView(bool value) async {
    setState(ViewState.busy);
    htmlEditorView = value;
    if (value) {
      postModel!.content = await editorController.getText();
    } else {
      postModel!.content = htmlController.text;
    }
    if (value) htmlController.text = postModel!.content;
    notifyListeners();
    setState(ViewState.idle);
  }

  void setReaderComments({bool? value}) {
    postModel!.readerComments = value ?? !postModel!.readerComments;
    notifyListeners();
  }

  void addHtmlTag({required String tag}) {
    final singleTags = ['br', 'hr'];

    // cursor position
    final selection = htmlController.selection;
    final currentText = htmlController.text;
    if (tag == '🏷️') tag = '';

    String tag1 = '<$tag>';
    String tag2 = '';
    if (!singleTags.contains(tag)) {
      tag2 = '</$tag>';
    }

    final newText =
        "${currentText.substring(0, selection.baseOffset)} $tag1$tag2 ${currentText.substring(selection.baseOffset)}";
    htmlController.text = newText;
    htmlController.selection =
        TextSelection.collapsed(offset: selection.baseOffset + tag1.length + 1);
  }

  Future<void> updatePostContent() async => postModel!.content =
      htmlEditorView ? htmlController.text : await editorController.getText();

  Future<void> updateHomePageModel() async {
    final homeViewModel = locator<HomeViewModel>();
    await homeViewModel.getContents();
  }

  Future<bool> updateContent() async {
    addState('sendContent');
    await updatePostContent();

    final response = await _dio.request(
        url: postModel!.selfLink,
        method: HttpMethod.put,
        data: postModel!.toJson());

    if (response == null) {
      deleteState('sendContent');
      return false;
    }

    deleteState('sendContent');
    return true;
  }

  void convertToDraft() async {
    addState('settings');
    final response = await _dio.request(
        url: '${postModel!.selfLink}/revert', method: HttpMethod.post);
    if (response != null) postModel!.status = PostStatus.draft;
    await updateHomePageModel();
    deleteState('settings');
  }

  Future<bool> publishDraft() async {
    addState('sendContent');

    final response = await _dio.request(
        url: '${postModel!.selfLink}/publish', method: HttpMethod.post);

    if (response == null) {
      deleteState('sendContent');
      return false;
    }
    postModel!.status = PostStatus.live; // zamanlı ise scheduled yap

    await updateHomePageModel();
    deleteState('sendContent');
    return true;
  }

  Future<bool> deleteContent() async {
    final response = await _dio.request(
        url: postModel!.selfLink,
        method: HttpMethod.delete,
        data: {"useTrash": true});

    if (response == null) {
      deleteState('deleteContent');
      return false;
    }

    await updateHomePageModel();
    return true;
  }
}
