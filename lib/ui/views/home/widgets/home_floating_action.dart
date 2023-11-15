import 'package:blogman/app/locator.dart';
import 'package:blogman/commons/extensions/notifier.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../commons/enums/post_filter_enum.dart';
import '../../../../commons/models/post_model.dart';
import '../../../../utils/colors.dart';

class CreateContentAction extends StatefulWidget {
  const CreateContentAction({super.key, this.onDraftCreated});
  final Function(PostModel postModel)? onDraftCreated;

  @override
  State<CreateContentAction> createState() => _CreateContentActionState();
}

class _CreateContentActionState extends State<CreateContentAction> {
  final _tTitleFocus = FocusNode();
  final _tTitle = TextEditingController();

  bool _active = false;

  void _setActive(bool value) {
    setState(() => _active = value);
    if (value) {
      _tTitleFocus.requestFocus();
    } else {
      _tTitle.clear();
      _tTitleFocus.unfocus();
    }
  }

  void _tTitleFocusListener() {
    if (!_tTitleFocus.hasFocus) _setActive(false);
  }

  @override
  void initState() {
    _tTitleFocus.addListener(_tTitleFocusListener);
    super.initState();
  }

  @override
  void dispose() {
    _setActive(false);
    _tTitleFocus.removeListener(_tTitleFocusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, model, child) {
        if (model.currentFilter == PostFilter.drafts) {
          return const SizedBox();
        }
        return _active
            ? _contentTitleFieldWidget(model)
            : FloatingActionButton(
                backgroundColor: KColors.orange,
                mini: true,
                onPressed: () => _setActive(true),
                child: const Icon(Icons.add, color: Colors.white),
              );
      },
    );
  }

  Widget _contentTitleFieldWidget(HomeViewModel model) {
    final isPage = model.currentFilter == PostFilter.pages;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 120,
          margin: const EdgeInsets.only(left: 50),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
          decoration: BoxDecoration(
            color: KColors.whiteSmoke,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: KColors.blueGray,
            ),
          ),
          child: TextFormField(
            controller: _tTitle,
            focusNode: _tTitleFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) async {
              final postModel = await locator<HomeViewModel>()
                  .createDraftContent(title: value);
              if (postModel == null && context.mounted) {
                context.showError();
              } else {
                widget.onDraftCreated?.call(postModel!);
              }
            },
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: KColors.whiteSmoke,
              hintText: isPage ? 'enterPageTitle'.tr() : 'enterPostTitle'.tr(),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: KColors.orange,
          mini: true,
          onPressed: () => _setActive(false),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }
}
