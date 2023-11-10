import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/colors.dart';
import '../../views/comments/comments_viewmodel.dart';
import '../../views/comments/models/comments_model.dart';

enum CommentActionTypes { approve, spam, delete }

class CommentActions extends StatelessWidget {
  const CommentActions({super.key, required this.comment});
  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsViewModel>(
      builder: (context, model, child) => model.isActiveState(comment.id)
          ? _commentActionConfirmDialog(
              onConfirm: (type) => switch (type) {
                (CommentActionTypes.delete) => model.deleteComment(comment),
                (CommentActionTypes.spam) => {},
                (CommentActionTypes.approve) => {}
              },
              model: model,
              comment: comment,
            )
          : Row(
              children: [
                if (comment.status == CommentStatus.pending) ...[
                  _commentActionButton(
                    onTap: () {},
                    text: 'approve'.tr(),
                    color: KColors.greenSea,
                  ),
                ],
                _commentActionButton(
                  onTap: () {},
                  text: 'spam'.tr(),
                  color: KColors.orange,
                ),
                _commentActionButton(
                  onTap: () =>
                      model.addState(comment.id, CommentActionTypes.delete),
                  text: 'delete'.tr(),
                  color: KColors.blue,
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

  Widget _commentActionConfirmDialog(
      {required CommentsViewModel model,
      required CommentModel comment,
      Function(CommentActionTypes type)? onConfirm}) {
    return Row(
      children: [
        _commentActionButton(
          onTap: () => model.deleteState(comment.id),
          text: 'cancel'.tr(),
          color: KColors.red,
        ),
        _commentActionButton(
          onTap: () => onConfirm?.call(model.getStateValue(comment.id)),
          text: 'approve'.tr(),
          color: KColors.blue,
        ),
      ],
    );
  }
}
