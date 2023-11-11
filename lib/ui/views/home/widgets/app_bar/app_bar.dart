import 'package:blogman/app/locator.dart';
import 'package:blogman/extensions/theme.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/utils/colors.dart';
import 'package:blogman/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../utils/images.dart';
import 'app_bar_viewmodel.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _HomeAppBarState extends State<HomeAppBar> {
  final _appBarViewModel = locator<AppBarViewModel>();
  final _homeViewModel = locator<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: ChangeNotifierProvider<AppBarViewModel>(
        create: (context) => locator<AppBarViewModel>(),
        child: Consumer<AppBarViewModel>(
          builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 17),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: !model.searchEnabled
                    ? _titleWidget(context)
                    : _searchBarWidget(model),
                transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.0, -0.5), end: Offset.zero)
                        .animate(animation),
                    child: child),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _searchIcon() {
    return IconButton(
        onPressed: _appBarViewModel.enableSearch,
        icon: Image.asset(KImages.search));
  }

  Row _titleWidget(BuildContext context) {
    return Row(
      key: const Key('title'),
      children: [
        InkWell(
            onTap: () => context.pushNamed('profile'),
            child: SvgPicture.asset(KImages.menu)),
        Expanded(
          child: Text(
            KStrings.appName,
            textAlign: TextAlign.center,
            style: context.appBarTitleStyle(),
          ),
        ),
        _searchIcon(),
      ],
    );
  }

  Row _searchBarWidget(AppBarViewModel model) {
    final textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black.withOpacity(.7),
    );
    const inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: KColors.blueGray),
    );
    return Row(
      key: const Key('search'),
      children: [
        _searchIcon(),
        const SizedBox(width: 5),
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: model.tSearch,
                focusNode: model.searchFocus,
                style: textStyle,
                cursorColor: KColors.blue,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _homeViewModel.setSearchText(value),
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  hintStyle: textStyle.copyWith(color: KColors.blueGray),
                  isDense: true,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder,
                ),
              ),
              InkWell(
                onTap: () {
                  model.cancelSearch();
                  _homeViewModel.setSearchText(null);
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: KColors.blueGray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 23),
      ],
    );
  }
}
