import 'package:flutter/material.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
    required this.title,
    required this.titleBgColor,
    required this.children,
    this.width,
    this.height,
  });
  final List<Widget> children;
  final String title;
  final Color titleBgColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              color: titleBgColor,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            color: Colors.grey.withOpacity(.04),
            padding: const EdgeInsets.all(12),
            width: width,
            height: height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileContainerTile extends StatelessWidget {
  const ProfileContainerTile(
      {super.key, this.onTap, required this.text, this.suffix});
  final VoidCallback? onTap;
  final String text;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0.0, 1.0),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(.03))
              ],
            ),
            child: Row(
              children: [
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (suffix != null) ...[const Spacer(), suffix!]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
