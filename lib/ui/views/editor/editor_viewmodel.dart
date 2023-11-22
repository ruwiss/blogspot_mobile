import 'package:blogman/commons/services/ads/ads.dart';
import 'package:blogman/ui/views/home/home_viewmodel.dart';
import 'package:blogman/utils/strings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

import '../../../core/base/base_viewmodel.dart';
import '../../../commons/enums/post_filter_enum.dart';
import '../../../commons/models/post_model.dart';
import '../../../core/core.dart';

class EditorViewModel extends BaseViewModel {
  InterstitialAd? _interstitialAd;

  final editorController = QuillEditorController();
  final htmlController = TextEditingController();

  final _dio = locator<HttpService>();

  bool htmlEditorView = false;

  // HTML Editor için hızlı etiket ekleme butonları
  final List<String> htmlToolbar = [
    "🏷️",
    "html",
    "head",
    "title",
    "p",
    "b",
    "i",
    "h1",
    "h2",
    "div",
    "br",
    "a",
    "img",
    "code",
    "hr",
    "blockquote",
    "ol",
    "ul",
    "li"
  ];

  PostModel? _postModel;
  PostModel? get postModel => _postModel;

  int contentLength = 0;

  DateTime? publishDate;

  // Mevcut paylaşımın sayfa veya post mu olduğunu getirir
  PostFilter currentPostFilter() {
    final selfLink = postModel!.selfLink;
    if (selfLink.contains('/posts/')) {
      return PostFilter.posts;
    }
    return PostFilter.pages;
  }

  // HTML içerik uzunluğu sayacı
  void setContentLength(int value) {
    contentLength = value;
    notifyListeners();
  }

  // İçerik zamanlama için seçilen tarihi kaydet
  void setPublishDate(DateTime? dateTime) {
    publishDate = dateTime;
    notifyListeners();
  }

  // Editor için görünecek araç listesi
  final customToolBarList = [
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.align,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.addTable,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
  ];

  // Sayfa açılınca gelen post verisini state üzerine kaydet
  void setPostModel(PostModel postModel) {
    _postModel = postModel;
    contentLength = postModel.content.length;
    if (postModel.status == PostStatus.scheduled) {
      publishDate = postModel.published;
    }
    notifyListeners();
  }

  // HTML düzenleyici görünümünü etkinleştir
  void setHtmlEditorView(bool value) async {
    setState(ViewState.busy);
    htmlEditorView = value;
    if (value) {
      // Text editör üzerindeki veriyi state üzerine aktar
      postModel!.content = await editorController.getText();
      // Ayrıca html editörde göstermek için editörün içeriğini güncelle
      htmlController.text = postModel!.content;
    } else {
      // Html editör üzerindeki veriyi state üzerine aktar
      postModel!.content = htmlController.text;
    }
    notifyListeners();
    setState(ViewState.idle);
  }

  void setReaderComments({bool? value}) {
    // Okuyucu yorumlarını aç veya kapat
    postModel!.readerComments = value ?? !postModel!.readerComments;
    notifyListeners();
  }

  // HTML Editör için hızlı etiket ekleyici
  void addHtmlTag({required String tag}) {
    // Buradaki etiketler eklenirken kapanış etiketi içermeyecek
    final singleTags = ['br', 'hr'];

    // cursor position
    final selection = htmlController.selection;
    final currentText = htmlController.text;
    if (tag == '🏷️') tag = '';

    String tag1 = '<$tag>';
    String tag2 = '';
    // Eğer mevcut etiket kapanış etiketlerinde yoksa kapanış etiketi oluştur
    if (!singleTags.contains(tag)) {
      tag2 = '</$tag>';
    }

    // Eklenecek etiket metnini, HTML Editör'de imlecin olduğu yere yerleştir.
    final newText =
        "${currentText.substring(0, selection.baseOffset)} $tag1$tag2 ${currentText.substring(selection.baseOffset)}";
    htmlController.text = newText;
    // Yerleşim sonrası imlecin konumunu etiketlerin <p> arasına </p> ayarla
    htmlController.selection =
        TextSelection.collapsed(offset: selection.baseOffset + tag1.length + 1);
  }

  // Editörlerdeki veriyi state üzerine kaydet
  Future<void> updatePostContent() async => postModel!.content =
      htmlEditorView ? htmlController.text : await editorController.getText();

  // İçerik güncellendiğinde ana sayfadaki verileri güncelle
  Future<void> updateHomePageModel() async {
    final homeViewModel = locator<HomeViewModel>();
    await homeViewModel.getContents();
  }

  // İçeriği güncelle
  Future<bool> updateContent() async {
    addState('sendContent');
    await updatePostContent();

    final response = await _dio.request(
        url: postModel!.selfLink,
        method: HttpMethod.put,
        data: postModel!.toJson());

    if (response == null) {
      deleteState('sendContent');
      return false;
    }
    showInterstitialAd();
    FirebaseAnalytics.instance.logEvent(name: 'updateContent');
    deleteState('sendContent');
    return true;
  }

  // Paylaşılan veya zamanlanan içeriği taslak haline getir
  void convertToDraft() async {
    addState('settings');
    final response = await _dio.request(
        url: '${postModel!.selfLink}/revert', method: HttpMethod.post);
    if (response != null) postModel!.status = PostStatus.draft;
    await updateHomePageModel();
    showInterstitialAd();

    FirebaseAnalytics.instance.logEvent(name: 'convertToDraft');
    deleteState('settings');
  }

  // Taslak halinde olan içeriği yayına gönder
  Future<bool> publishDraft() async {
    addState('sendContent');

    Map<String, dynamic> data = {};

    // İçerik zamanlanmışsa UTC zaman tipine dönüştür ve gönderime hazırla
    if (publishDate != null) {
      data['publishDate'] = publishDate!.toUtc().toIso8601String();
    }

    final response = await _dio.request(
      url: '${postModel!.selfLink}/publish',
      method: HttpMethod.post,
      data: data,
    );

    if (response == null) {
      deleteState('sendContent');
      return false;
    }

    // İçerik zamanlanmışsa veya canlı paylaşılmışsa state verisini güncelle
    postModel!.status =
        publishDate != null ? PostStatus.scheduled : PostStatus.live;

    await updateHomePageModel();
    showInterstitialAd();

    FirebaseAnalytics.instance.logEvent(name: 'publishDraft');
    deleteState('sendContent');
    return true;
  }

  // İçeriği sil
  Future<bool> deleteContent() async {
    final response = await _dio.request(
        url: postModel!.selfLink,
        method: HttpMethod.delete,
        // [useTrash]: Blogger üzerindeki çöp kutusuna gönderir
        data: {"useTrash": true});

    if (response == null) {
      deleteState('deleteContent');
      return false;
    }
    showInterstitialAd();
    FirebaseAnalytics.instance.logEvent(name: 'deleteContent');
    await updateHomePageModel();
    return true;
  }

  void loadInterstitialAd() {
    if (_interstitialAd == null) {
      InterstitialAdService(
          adUnitId: KStrings.interstitial1,
          onLoaded: (ad) => _interstitialAd = ad);
    }
  }

  void showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
