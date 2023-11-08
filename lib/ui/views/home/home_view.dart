import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/app/locator.dart';
import 'package:blogman/extensions/notifier.dart';
import 'package:blogman/models/post_model.dart';
import 'package:blogman/ui/widgets/home/app_bar/app_bar.dart';
import 'package:blogman/ui/widgets/home/app_bar/app_bar_viewmodel.dart';
import 'package:blogman/ui/widgets/home/post_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/base/base_view.dart';
import '../../../utils/colors.dart';
import '../../widgets/home/post_item.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key, required this.blogId});
  final String blogId;

  final _scrollController = ScrollController();

  Future<bool> _willPopScope(HomeViewModel model) async {
    final appBarViewModel = locator<AppBarViewModel>();
    if (appBarViewModel.searchEnabled) {
      appBarViewModel.cancelSearch();
      model.getContents();
      return false;
    } else if (model.isFilterChanged) {
      model.clearOrderFilter();
      model.getContents();
      return false;
    }
    return true;
  }

  void _scrollListener(HomeViewModel model) {
    if (_scrollController.position.extentAfter < 500) {
      model.getContents(
          pageToken: model.postListModel?.nextPageToken, loadMore: true);
    }
  }

  void _initState(BuildContext context, HomeViewModel model) async {
    _scrollController.addListener(() => _scrollListener(model));
    // Blog postlarını getir, hata olursa göster.
    model.setBlogId(blogId);
    if (!await model.getContents() && context.mounted) context.showError();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      onModelReady: (model) => _initState(context, model),
      builder: (context, model, child) {
        final PostListModel? postList = model.postListModel;
        return WillPopScope(
          onWillPop: () => _willPopScope(model),
          child: Scaffold(
            appBar: const HomeAppBar(),
            body: Center(
              child: Column(
                children: [
                  PostFilterWidget(),
                  const SizedBox(height: 22),

                  // Postlar geldiyse
                  if (model.state == ViewState.idle && postList != null)
                    _postBody(postList: postList),

                  // Daha fazla yükle (loading bar)
                  if (model.scrollIndicatorActive)
                    const LinearProgressIndicator(color: KColors.orange),

                  // Post gelmediyse
                  if (model.state == ViewState.idle && postList == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'unknownError'.tr(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(.7)),
                      ),
                    ),
                    _bodyView(
                      child: Center(
                        child: IconButton(
                          onPressed: model.getContents,
                          icon: const Icon(
                            Icons.refresh,
                            color: KColors.blueGray,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (model.state == ViewState.busy)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(color: KColors.blue),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bodyView({required Widget child}) {
    return Expanded(
      child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: KColors.homeLinearGradient,
            ),
          ),
          child: child),
    );
  }

  Widget _postBody({required PostListModel postList}) {
    return _bodyView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.5),
        child: postList.items.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_view_day_sharp,
                    size: 100,
                    color: KColors.blueGray,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 50),
                    child: Text(
                      'noPost'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(.6),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: postList.items.length,
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    PostItem(postModel: postList.items[index]),
              ),
      ),
    );
  }
}
