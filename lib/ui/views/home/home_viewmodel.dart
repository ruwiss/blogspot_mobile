import '../../../app/base/base_viewmodel.dart';
import '../../../app/locator.dart';
import '../../../enums/post_filter_enum.dart';
import '../../../models/post_model.dart';
import '../../../services/http_service.dart';
import '../../../utils/strings.dart';
import 'widgets/app_bar/app_bar_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final _appBarViewModel = locator<AppBarViewModel>();
  PostFilter currentFilter = PostFilter.posts;
  late String blogId;
  String? searchText;
  bool isSearch = false;

  final _dio = locator<HttpService>();
  PostListModel? postListModel;

  SortOption sortOption = SortOption.descending;
  PostStatus postStatus = PostStatus.live;

  bool scrollIndicatorActive = false;

  String lastUsedToken = "";

  Map<String, dynamic> get getPostArgs => {
        "view": "ADMIN",
        "fetchImages": true,
        "maxResults": 15,
        "status": switch (currentFilter) {
          // Postlarda zamanlama özelliği vardır.
          (PostFilter.posts) => postStatus.name,
          // Draft olanlarda zamanlama özelliği yoktur.
          // Bu nedenle sadece draft veriyoruz
          (PostFilter.drafts) => PostStatus.draft.name,
          // Sayfalarda zamanlanmış özelliği yoktur.
          (PostFilter.pages) => PostStatus.live.name
        },
        // ascending, descending | Arama isteği ise sıralama belirtmiyoruz.
        "sortOption": searchText != null ? "" : sortOption.name
      };

  bool isFilterChanged = false;

  void setCurrentFilter(PostFilter filter) {
    bool getContent = false;
    if (_appBarViewModel.searchEnabled) {
      _appBarViewModel.cancelSearch();
      setSearchText(null);
      getContent = true;
    }
    if (currentFilter != filter) {
      currentFilter = filter;
      notifyListeners();
      getContent = true;
    } else if (isFilterChanged) {
      // Filtre uygulanmışsa ve aynı kategoriye tıklanmışsa filtreyi kaldır.
      clearOrderFilter();
      getContent = true;
    }
    if (getContent) getContents();
  }

  void setBlogId(String blogId) => this.blogId = blogId;

  void setSearchText(String? value) {
    if (value != null && value.trim().isEmpty) value = null;
    if (value != null) isSearch = true;
    searchText = value;
    notifyListeners();

    if (isSearch || (!isSearch && value != null)) {
      // İlk aramada tümünde araması için filtreyi devre dışı bırakıyoruz.
      clearOrderFilter();
      getContents();
    }

    if (value == null && isSearch) isSearch = false;
  }

  void setOrder(OtherFilter otherFilter) {
    switch (otherFilter) {
      case OtherFilter.scheduled:
        // değer değiştiyse
        if (currentFilter == PostFilter.posts) {
          if (postStatus != PostStatus.scheduled) isFilterChanged = true;
          postStatus = PostStatus.scheduled;
        }
        break;
      case OtherFilter.ascending:
        // değer değiştiyse
        if (sortOption != SortOption.ascending) isFilterChanged = true;
        sortOption = SortOption.ascending;
        break;
      case OtherFilter.descending:
        // değer değiştiyse
        if (sortOption != SortOption.descending) isFilterChanged = true;
        sortOption = SortOption.descending;
        break;
      case OtherFilter.defaultValues:
        if (sortOption != SortOption.descending ||
            postStatus != PostStatus.live) {
          clearOrderFilter();
          getContents();
        }
        break;
    }
    if (isFilterChanged) {
      lastUsedToken = '';
      getContents();
    }

    notifyListeners();
  }

  void clearOrderFilter() {
    sortOption = SortOption.descending;
    postStatus = PostStatus.live;
    lastUsedToken = '';
    isFilterChanged = false;
  }

  void setScrollIndicatorActive(bool value) {
    scrollIndicatorActive = value;
    notifyListeners();
  }

  Future<bool> getContents({String? pageToken, bool loadMore = false}) async {
    // Load More [Token] kullanıldıysa tekrar aynı içerikleri getirme
    if (loadMore) {
      if (state == ViewState.busy || scrollIndicatorActive) return true;
      if (pageToken != null && pageToken != lastUsedToken) {
        lastUsedToken = pageToken;
        setScrollIndicatorActive(true);
      } else {
        return true;
      }
    }

    if (searchText != null) {
      return await getSearchList(pageToken: pageToken);
    } else if (currentFilter == PostFilter.drafts) {
      return await getDraftList(pageToken: pageToken);
    } else {
      return await getContentList(pageToken: pageToken);
    }
  }

  Future<bool> getContentList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      args['pageToken'] = pageToken;
    } else {
      setState(ViewState.busy);
    }

    final response = await _dio.request(
      url: KStrings.getContentList(blogId: blogId, type: currentFilter),
      data: args,
      method: HttpMethod.get,
    );

    if (response == null) {
      setState(ViewState.idle);
      setScrollIndicatorActive(false);
      return false;
    }

    final postList = PostListModel.fromJson(response.data);

    if (pageToken == null) {
      postListModel = postList;
    } else {
      postListModel?.nextPageToken = postList.nextPageToken;
      postListModel?.items.addAll(postList.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  Future<bool> getDraftList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      args['pageToken'] = pageToken;
    } else {
      setState(ViewState.busy);
    }

    final pageDraftsResponse = await _dio.request(
        url: KStrings.getDraftList(blogId: blogId, draftType: PostFilter.pages),
        data: getPostArgs,
        method: HttpMethod.get);

    final postDraftsResponse = await _dio.request(
        url: KStrings.getDraftList(blogId: blogId, draftType: PostFilter.posts),
        data: args,
        method: HttpMethod.get);

    if (postDraftsResponse == null || pageDraftsResponse == null) {
      setState(ViewState.idle);
      setScrollIndicatorActive(false);
      return false;
    }
    final pageModel = PostListModel.fromJson(pageDraftsResponse.data);
    final postModel = PostListModel.fromJson(postDraftsResponse.data);

    if (pageToken == null) {
      postListModel = pageModel;
      postListModel?.items.addAll(postModel.items);
    } else {
      postListModel?.nextPageToken = pageModel.nextPageToken;
      postListModel?.items.addAll(pageModel.items);
      postListModel?.items.addAll(postModel.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  Future<bool> getSearchList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      args['pageToken'] = pageToken;
    } else {
      setState(ViewState.busy);
    }

    args['q'] = searchText!;
    final response = await _dio.request(
      url: KStrings.getSearchList(blogId: blogId),
      data: args,
      method: HttpMethod.get,
    );

    if (response == null) {
      setState(ViewState.idle);
      setScrollIndicatorActive(false);
      return false;
    }

    final postList = PostListModel.fromJson(response.data);

    if (pageToken == null) {
      postListModel = postList;
    } else {
      postListModel?.nextPageToken = postList.nextPageToken;
      postListModel?.items.addAll(postList.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  Future<PostModel?> createDraftContent({required String title}) async {
    final draftType =
        currentFilter == PostFilter.pages ? PostFilter.pages : PostFilter.posts;

    final response = await _dio.request(
        url: KStrings.createDraftContent(blogId: blogId, type: draftType),
        data: {"title": title},
        method: HttpMethod.post);

    if (response == null) return null;

    return PostModel.fromJson(response.data);
  }
}
