import 'package:flutter/material.dart';

class FavoriteContactWidget extends StatelessWidget {
  final String name;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const FavoriteContactWidget({
    Key? key,
    required this.name,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials =
        name.split(' ').map((part) => part.isNotEmpty ? part[0] : '').join();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.blue[200],
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Droid',
            ),
          ),
        ),
      ),
    );
  }
}
