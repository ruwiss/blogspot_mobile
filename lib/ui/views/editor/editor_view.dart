import 'package:blogman/models/post_model.dart';
import 'package:blogman/ui/views/editor/widgets/editor_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'editor_viewmodel.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.postModel});
  final PostModel postModel;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
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
      builder: (context, model, child) => Scaffold(
        appBar: EditorAppBar(
          title: model.postModel?.title ?? widget.postModel.title,
        
        ),
        body: Center(
          child: Text('editor'),
        ),
      ),
    );
  }
}
