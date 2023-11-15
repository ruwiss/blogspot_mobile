import '../../../core/base/base_viewmodel.dart';
import '../../../core/locator.dart';
import '../../../commons/enums/post_filter_enum.dart';
import '../../../commons/models/post_model.dart';
import '../../../commons/services/services.dart';
import '../../../utils/utils.dart';
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

  // Ana sayfa http istekleri için gönderilecek veriler
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

  // Ana sayfada gösterilecek verileri filtrele
  void setCurrentFilter(PostFilter filter) {
    bool getContent = false;

    // Arama kutusu açıksa kapat ve aramayı durdur
    if (_appBarViewModel.searchEnabled) {
      _appBarViewModel.cancelSearch();
      setSearchText(null);
      getContent = true;
    }

    // Yeni bir filtre uygulanmışsa yeni içerikleri getir
    if (currentFilter != filter) {
      currentFilter = filter;
      notifyListeners();
      getContent = true;
    } else if (isFilterChanged) {
      // Filtre uygulanmışsa ve aynı kategoriye tıklanmışsa filtreyi kaldır
      clearOrderFilter();
      getContent = true;
    }

    // İçerik getirilmesi gerekiyorsa getir
    if (getContent) getContents();
  }

  // İçeriklerin hangi blogdan alınacağını kaydet
  void setBlogId(String blogId) => this.blogId = blogId;

  // İçerikler arasında arama yap
  void setSearchText(String? value) {
    // Arama kutusu boşsa aramayı kapat
    if (value != null && value.trim().isEmpty) value = null;

    // Arama kutusu boş değilse arama yap
    if (value != null) isSearch = true;
    searchText = value;
    notifyListeners();

    if (isSearch || (!isSearch && value != null)) {
      // Tümünde araması için filtreyi devre dışı bırakıyoruz.
      clearOrderFilter();
      getContents();
    }

    // Aramayı filtre uygularken kapatmak için
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
      // Filtreyi sıfırla
      case OtherFilter.defaultValues:
        if (sortOption != SortOption.descending ||
            postStatus != PostStatus.live) {
          clearOrderFilter();
          getContents();
        }
        break;
    }
    // Filtre değiştiğinde kaydırdıkça yükleme için token değerini sıfırla
    if (isFilterChanged) {
      lastUsedToken = '';
      getContents();
    }

    notifyListeners();
  }

  // Sıralama filtresini varsayılan yap
  void clearOrderFilter() {
    sortOption = SortOption.descending;
    postStatus = PostStatus.live;
    lastUsedToken = '';
    isFilterChanged = false;
  }

  // Kaydırdıkça yükleme için yükleme görünümünü aktif et
  void setScrollIndicatorActive(bool value) {
    scrollIndicatorActive = value;
    notifyListeners();
  }

  // İçerik getirme bölümü
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
      // İçerik araması ise
      return await getSearchList(pageToken: pageToken);
    } else if (currentFilter == PostFilter.drafts) {
      // Yalnızca taslakları getir
      return await getDraftList(pageToken: pageToken);
    } else {
      // Diğer içerikleri getir
      return await getContentList(pageToken: pageToken);
    }
  }

  // Duruma göre uygun içerikleri getir
  Future<bool> getContentList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      // Kaydırdıkça yükleme ise token verisini isteğe hazırla
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
      // Kaydırdıkça yükleme değilse post direkt kaydedilir
      postListModel = postList;
    } else {
      // Kaydırdıkça yükleme varsa yeni token state üzerine kaydedilir
      // Gelen veriler önceki verilerin sonuna eklenir
      postListModel?.nextPageToken = postList.nextPageToken;
      postListModel?.items.addAll(postList.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  // Taslak listesini getir
  Future<bool> getDraftList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      // Kaydırdıkça yükleme ise token verisini isteğe hazırla
      args['pageToken'] = pageToken;
    } else {
      setState(ViewState.busy);
    }

    // Sayfa ve Postlar için taslaklar ayrı olduğundan her ikisini de alıp
    // daha sonra birleştiriyoruz

    // Sayfa taslaklarını getir
    final pageDraftsResponse = await _dio.request(
        url: KStrings.getDraftList(blogId: blogId, draftType: PostFilter.pages),
        data: getPostArgs,
        method: HttpMethod.get);

    // Post taslaklarını getir
    final postDraftsResponse = await _dio.request(
        url: KStrings.getDraftList(blogId: blogId, draftType: PostFilter.posts),
        data: args,
        method: HttpMethod.get);

    // Veriler gelmediyse
    if (postDraftsResponse == null || pageDraftsResponse == null) {
      setState(ViewState.idle);
      setScrollIndicatorActive(false);
      return false;
    }

    final pageModel = PostListModel.fromJson(pageDraftsResponse.data);
    final postModel = PostListModel.fromJson(postDraftsResponse.data);

    if (pageToken == null) {
      // Kaydırdıkça yükleme değilse verileri birleştir ve kaydet
      postListModel = pageModel;
      postListModel?.items.addAll(postModel.items);
    } else {
      // Kaydırdıkça yükleme varsa yeni tokeni state üzerine kaydet
      // Ayrıca gelen verileri mevcut verilerin sonuna ekle
      postListModel?.nextPageToken = pageModel.nextPageToken;
      postListModel?.items.addAll(pageModel.items);
      postListModel?.items.addAll(postModel.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  // İçerik üzerinde arama yap
  Future<bool> getSearchList({String? pageToken}) async {
    Map<String, dynamic> args = getPostArgs;
    if (pageToken != null) {
      // Kaydırdıkça yükleme ise token verisini isteğe hazırla
      args['pageToken'] = pageToken;
    } else {
      setState(ViewState.busy);
    }

    // Arama metnini isteğe hazırla
    args['q'] = searchText!;

    final response = await _dio.request(
      url: KStrings.getSearchList(blogId: blogId),
      data: args,
      method: HttpMethod.get,
    );

    // İçerik gelmediyse
    if (response == null) {
      setState(ViewState.idle);
      setScrollIndicatorActive(false);
      return false;
    }

    final postList = PostListModel.fromJson(response.data);

    if (pageToken == null) {
      // Kaydırdıkça yükleme değilse içeriği state üzerine kaydet
      postListModel = postList;
    } else {
      // Kaydırdıkça yükleme ise yeni tokeni state üzerine kaydet
      // Ayrıca gelen verileri mevcut olan içeriğin sonuna ekle
      postListModel?.nextPageToken = postList.nextPageToken;
      postListModel?.items.addAll(postList.items);
    }

    setState(ViewState.idle);
    setScrollIndicatorActive(false);
    return true;
  }

  // Boş bir taslak oluştur [Page, Post] ayrı olarak
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
