import 'package:blogman/core/base/base_viewmodel.dart';
import 'package:blogman/commons/extensions/notifier.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../core/base/base_view.dart';
import '../../../commons/models/models.dart';
import '../../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'home_viewmodel.dart';
import 'widgets/app_bar/app_bar_viewmodel.dart';
import 'widgets/home_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.blogId});
  final String blogId;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();

  // Geri butonuna basılırsa arama kutusu etkinse kapat
  // Filtre uygulanmışsa filtreyi kaldır. Aksi halde uygulamadan çık
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

  // Kaydırdıkça yükleme dinleyicisi
  void _scrollListener(HomeViewModel model) {
    if (_scrollController.position.extentAfter < 500) {
      model.getContents(
          pageToken: model.postListModel?.nextPageToken, loadMore: true);
    }
  }

  void _initState(BuildContext context, HomeViewModel model) async {
    // Splash logoyu gizle
    locator<AuthViewModel>().hideSplash();

    // Kaydırdıkça yükleme için dinleyiciyi çalıştır
    _scrollController.addListener(() => _scrollListener(model));

    // Blog postlarını getir, hata olursa göster.
    model.setBlogId(widget.blogId);
    if (!await model.getContents() && context.mounted) context.showError();
  }

  void _dispose(HomeViewModel model) {
    _scrollController.removeListener(() => _scrollListener(model));
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      onModelReady: (model) => _initState(context, model),
      dispose: _dispose,
      builder: (context, model, child) {
        final PostListModel? postList = model.postListModel;
        return WillPopScope(
          onWillPop: () => _willPopScope(model),
          child: Scaffold(
            appBar: const HomeAppBar(),
            floatingActionButton: CreateContentAction(
              onDraftCreated: (postModel) {
                context.pushNamed('editor', extra: postModel);
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
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
        padding: const EdgeInsets.only(top: 11.5),
        child: postList.items.isEmpty
            ? const NoItemWidget()
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
