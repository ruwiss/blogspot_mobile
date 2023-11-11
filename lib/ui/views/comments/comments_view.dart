import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/ui/views/comments/models/comments_model.dart';
import 'package:blogman/ui/widgets/comments/comment_actions.dart';
import 'package:blogman/ui/widgets/shared/no_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../widgets/shared/page_title.dart';
import '../../widgets/shared/profile_widget.dart';
import 'comments_viewmodel.dart';

class CommentsView extends StatefulWidget {
  const CommentsView({super.key, this.commentUrl, this.isPending = false});
  final String? commentUrl;
  final bool isPending;

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      Provider.of<CommentsViewModel>(context, listen: false)
          .loadMoreComments(widget.commentUrl);
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() => _scrollListener());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentsViewModel>(context, listen: false).getComments(
          commentUrl: widget.commentUrl, isPending: widget.isPending);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsViewModel>(
      builder: (context, model, child) => Scaffold(
        appBar: PageTitle(
            title: widget.isPending ? 'pendingComments'.tr() : 'comments'.tr()),
        body: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          alignment: Alignment.topCenter,
          child: model.commentsModel == null && model.state == ViewState.busy
              ? const CircularProgressIndicator(color: KColors.blue)
              : model.commentsModel == null ||
                      model.commentsModel!.items.isEmpty
                  ? const NoItemWidget()
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: model.commentsModel!.items.length,
                      itemBuilder: (context, index) {
                        final CommentModel comment =
                            model.commentsModel!.items[index];
                        return Column(
                          children: [
                            _commentWidget(comment, model),
                            if (model.isActiveState('loadMore') &&
                                index == model.commentsModel!.items.length - 1)
                              const LinearProgressIndicator()
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Container _commentWidget(CommentModel comment, CommentsViewModel model) {
    final inReplyToComment = model.findCommentFromId(comment.inReplyTo);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: switch (comment.status) {
            (CommentStatus.spam) => KColors.red.withOpacity(.1),
            (CommentStatus.pending) => KColors.commentPending,
            (_) => Colors.grey.shade100,
          }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileWidget(
            authorModel: comment.author,
            date: (comment.published, comment.updated),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              comment.content.formatHtml(),
              style: TextStyle(
                color: Colors.black.withOpacity(.6),
              ),
            ),
          ),
          Row(
            children: [
              if (comment.inReplyTo != null)
                Text(
                  inReplyToComment != null
                      ? '@${inReplyToComment.author.displayName}'
                      : 'inReplyTo'.tr(),
                  style: const TextStyle(color: KColors.commentTagColor),
                ),
              const Spacer(),
              CommentActions(comment: comment),
            ],
          )
        ],
      ),
    );
  }
}
