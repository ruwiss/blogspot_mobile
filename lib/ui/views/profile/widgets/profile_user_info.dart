import 'package:blogman/core/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/router.dart';
import '../../../../utils/utils.dart';

class ProfileUserInfo extends StatelessWidget {
  const ProfileUserInfo({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
      decoration: BoxDecoration(
        color: KColors.softWhite2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            offset: const Offset(0.0, 2.5),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [_userImage(user), _userInfo(user)]),
          _signOutButton()
        ],
      ),
    );
  }

  Material _signOutButton() {
    final authViewModel = locator<AuthViewModel>();
    bool inProgress = false;
    return Material(
      color: Colors.white,
      child: StatefulBuilder(
        builder: (context, setState) {
          return InkWell(
            onTap: () async {
              if (inProgress) return;
              setState(() => inProgress = true);
              await authViewModel.signOut();
              authViewModel.setBlogList(null);
              resetApp();
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: KColors.lightGray),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                inProgress ? 'waiting'.tr() : 'signOut'.tr(),
                style: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Column _userInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.displayName}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(.6),
          ),
        ),
        Text(
          '${user.email}',
          style: const TextStyle(
            color: KColors.lightGray,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Padding _userImage(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipOval(
        child: user.photoURL != null
            ? Image.network(
                user.photoURL!,
                width: 45,
                height: 45,
              )
            : Image.asset(
                KImages.avatar,
                width: 45,
                height: 45,
              ),
      ),
    );
  }
}
