import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/locator.dart';
import '../../../../commons/enums/post_filter_enum.dart';

class PostFilterWidget extends StatelessWidget {
  PostFilterWidget({super.key});
  final _homeViewModel = locator<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _filterItem(PostFilter.posts),
        _filterItem(PostFilter.pages),
        _filterItem(PostFilter.drafts),
        if (_homeViewModel.searchText == null) _otherFilters(),
      ],
    );
  }

  Widget _filterItem(PostFilter filter) {
    final bool isActive = _homeViewModel.currentFilter == filter;
    return InkWell(
      onTap: () => _homeViewModel.setCurrentFilter(filter),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
            color: isActive ? KColors.blue : null,
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          switch (filter) {
            (PostFilter.posts) => 'posts'.tr(),
            (PostFilter.pages) => 'pages'.tr(),
            (PostFilter.drafts) => 'drafts'.tr(),
          },
          style: TextStyle(
            color: isActive ? Colors.white : KColors.blueGray,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _otherFilters() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: PopupMenuButton(
        onSelected: (value) => _homeViewModel.setOrder(value),
        constraints: const BoxConstraints(maxWidth: 120),
        itemBuilder: (context) => [
          if (_homeViewModel.isFilterChanged)
            _otherFilterItem(OtherFilter.defaultValues),
          if (_homeViewModel.currentFilter == PostFilter.posts)
            _otherFilterItem(OtherFilter.scheduled, icon: Icons.timer),
          _otherFilterItem(OtherFilter.ascending,
              enabled: _homeViewModel.sortOption != SortOption.ascending),
          _otherFilterItem(OtherFilter.descending,
              enabled: _homeViewModel.sortOption != SortOption.descending),
        ],
        child: const Icon(
          Icons.tune,
          color: KColors.blueGray,
        ),
      ),
    );
  }

  PopupMenuItem<OtherFilter> _otherFilterItem(OtherFilter filter,
      {IconData? icon, bool enabled = true}) {
    final bool isDefaultValues = filter == OtherFilter.defaultValues;
    return PopupMenuItem(
      value: filter,
      enabled: enabled,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            switch (filter) {
              (OtherFilter.defaultValues) => 'defaultValues'.tr(),
              (OtherFilter.scheduled) => 'scheduled'.tr(),
              (OtherFilter.ascending) => 'ascending'.tr(),
              (OtherFilter.descending) => 'descending'.tr(),
            },
            style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isDefaultValues ? FontWeight.w800 : FontWeight.w600),
          ),
          if (icon != null) Icon(icon, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}
