// widgets/logo_widget.dart
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, this.size = 120});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}
