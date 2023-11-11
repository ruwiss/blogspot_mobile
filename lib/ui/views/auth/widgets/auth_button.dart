import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final Color bgColor;
  final Widget icon;
  final String text;
  final VoidCallback? onTap;

  const AuthButton({
    super.key,
    this.onTap,
    required this.bgColor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(.25),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.4),
            height: 50,
            width: 260,
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  color: Colors.white,
                  child: icon,
                ),
                const Spacer(),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
