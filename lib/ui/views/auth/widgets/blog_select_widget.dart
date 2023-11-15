import 'dart:async';
import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../commons/services/shared_preferences/settings.dart';
import '../../../../utils/colors.dart';
import '../models/blog_model.dart';

class BlogSelectWidget extends StatefulWidget {
  const BlogSelectWidget(
      {super.key, required this.model, required this.onError});
  final AuthViewModel model;
  final Function(String error)? onError;

  @override
  State<BlogSelectWidget> createState() => _BlogSelectWidgetState();
}

class _BlogSelectWidgetState extends State<BlogSelectWidget> {
  String? _touchedBlogId;

  void _navigateScreen(String selectedId) async {
    if (!await  widget.model.checkUserBlogAccess()) {
      widget.onError?.call('limitedBlogError'.tr());
      return;
    }
    locator<AppSettings>().selectBlog(selectedId);
    if (mounted) {
      context
          .pushReplacementNamed('home', pathParameters: {'blogId': selectedId});
    }
  }

  void _setActive(String? v, {bool tap = false}) {
    setState(() => _touchedBlogId = v);
    if (tap) {
      Timer.periodic(const Duration(milliseconds: 300), (timer) {
        setState(() => _touchedBlogId = null);
        timer.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogList = widget.model.blogList!;
    final selectedId = widget.model.selectedBlog?.id;
    return Column(
      key: const Key('selectBlog'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        selectedId != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                    onPressed: () => _navigateScreen(selectedId),
                    child: const Text(
                      'continue',
                      style: TextStyle(
                          color: KColors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ).tr()),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  'chooseBlog'.tr(),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black.withOpacity(.8),
                      fontWeight: FontWeight.w600),
                ),
              ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 2 - 50,
          child: ListView.builder(
            itemCount: blogList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final BlogModel blogModel = blogList[index];
              final bool differentColor = index % 2 == 0;
              final bool isSelected = selectedId == blogModel.id;
              return Column(
                children: [
                  _blogListItem(
                    blogModel: blogModel,
                    differentColor: differentColor,
                    isSelected: isSelected,
                  ),
                  if (index == blogList.length - 1) const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Padding _blogListItem({
    required BlogModel blogModel,
    required bool differentColor,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: GestureDetector(
        onTap: () {
          _setActive(blogModel.id, tap: true);
          widget.model.setSelectedBlog(blogModel);
        },
        onTapDown: (_) => _setActive(blogModel.id),
        onTapUp: (_) => _setActive(null),
        onTapCancel: () => _setActive(null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _touchedBlogId == blogModel.id
                ? Colors.white
                : differentColor
                    ? KColors.antiqueWhite
                    : KColors.whiteSmoke,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(2, 2),
                  color: differentColor
                      ? KColors.orange.withOpacity(.3)
                      : KColors.blue.withOpacity(.28),
                  spreadRadius: 1)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                blogModel.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: KColors.dark, fontSize: 15),
              ),
              SvgPicture.asset(
                !isSelected ? KImages.checkOutline : KImages.check,
              )
            ],
          ),
        ),
      ),
    );
  }
}
