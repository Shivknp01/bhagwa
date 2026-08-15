import 'package:flutter/material.dart';

class DaivikLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const DaivikLogo({
    super.key,
    this.size = 120.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/daivik_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Clean fallback if image asset is loading
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF7A00),
            ),
            child: const Text('ॐ', style: TextStyle(fontSize: 42, color: Colors.white)),
          );
        },
      ),
    );
  }
}
