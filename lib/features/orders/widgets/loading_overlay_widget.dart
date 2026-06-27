import 'package:flutter/material.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final bool isLoading;
  final Color color;

  const LoadingOverlayWidget({
    Key? key,
    required this.isLoading,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
