import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextExtensions on BuildContext {
  void previewImage(String url) {
    showDialog(
      context: this,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: TapRegion(
          onTapOutside: (event) => context.pop(),
          child: Center(
            child: InteractiveViewer(
              maxScale: 3.0,
              minScale: 0.5,
              boundaryMargin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
