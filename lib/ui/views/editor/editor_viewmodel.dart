import 'package:blogman/models/post_model.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

import '../../../app/base/base_viewmodel.dart';

class EditorViewModel extends BaseViewModel {
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
    ToolBarStyle.link,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];

  void setPostModel(PostModel postModel) {
    _postModel = postModel;
    setContentLength(postModel.content.length);
    notifyListeners();
  }
}
