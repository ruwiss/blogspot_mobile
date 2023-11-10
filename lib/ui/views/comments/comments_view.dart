import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:blogman/extensions/string_formatter.dart';
import 'package:blogman/ui/views/comments/models/comments_model.dart';
import 'package:blogman/ui/widgets/shared/no_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../widgets/shared/page_title.dart';
import '../../widgets/shared/profile_widget.dart';
import 'comments_viewmodel.dart';

class CommentsView extends StatefulWidget {
  const CommentsView({super.key, this.postId});
  final String? postId;

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentsViewModel>(context, listen: false)
          .getComments(widget.postId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsViewModel>(
      builder: (context, model, child) => Scaffold(
        appBar: PageTitle(
            title: widget.postId == null
                ? 'pendingComments'.tr()
                : 'comments'.tr()),
        body: Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.topCenter,
          child: model.commentsModel == null && model.state == ViewState.busy
              ? const CircularProgressIndicator(color: KColors.blue)
              : model.commentsModel == null ||
                      model.commentsModel!.items.isEmpty
                  ? const NoItemWidget()
                  : ListView.builder(
                      itemCount: model.commentsModel!.items.length,
                      itemBuilder: (context, index) {
                        final CommentModel comment =
                            model.commentsModel!.items[index];
                        return _commentWidget(comment, model);
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
          borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
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
              if (comment.status == CommentStatus.pending)
                _commentActionButton(
                  onTap: () {},
                  text: 'approve'.tr(),
                  color: KColors.greenSea,
                ),
              _commentActionButton(
                onTap: () {},
                text: 'spam'.tr(),
                color: KColors.orange,
              ),
              _commentActionButton(
                onTap: () {},
                text: 'delete'.tr(),
                color: KColors.blue,
              )
            ],
          )
        ],
      ),
    );
  }

  TextButton _commentActionButton({
    required String text,
    required Color color,
    Function()? onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 6)),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
