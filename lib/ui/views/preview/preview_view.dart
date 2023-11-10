import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/base/base_view.dart';
import 'preview_viewmodel.dart';

class PreviewView extends StatelessWidget {
  const PreviewView({super.key, required this.postId});
  final String postId;

  void _initState(PreviewViewModel model) {
    // https://www.youtube.com/watch?v=qYnVdXCU1M0
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PreviewViewModel>(
      onModelReady: _initState,
      builder: (context, model, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: KColors.softWhite2,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: KColors.dark),
                ),
                actions: _appBarActions(),
                expandedHeight: 300,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _appBarActions() {
    Widget divider() => const SizedBox(
          height: 15,
          child: VerticalDivider(color: KColors.blueGray, width: 15),
        );
    return [
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.share, color: KColors.blueGray),
      ),
      divider(),
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.remove_red_eye, color: KColors.blueGray),
      ),
      divider(),
      Text(
        'edit'.tr(),
        style: const TextStyle(
          color: KColors.blueGray,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(width: 15),
    ];
  }
}
