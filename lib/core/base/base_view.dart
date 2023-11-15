import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_viewmodel.dart';
import '../locator.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final Function(T model)? onModelReady;
  final Function(T model)? dispose;

  const BaseView(
      {super.key, required this.builder, this.onModelReady, this.dispose});

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onModelReady?.call(model));
    super.initState();
  }

  @override
  void dispose() {
    widget.dispose?.call(model);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (BuildContext context) => model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}
