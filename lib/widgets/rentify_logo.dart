import 'package:flutter/material.dart';

class RentifyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const RentifyLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? const Color(0xFF0066FF);
    final textColor = color ?? (isDark ? Colors.white : const Color(0xFF1E293B));
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.vpn_key_rounded,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'Rentify',
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}
