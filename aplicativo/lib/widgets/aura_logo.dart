import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuraLogo extends StatelessWidget {
  final double size;
  final bool showLabel;
  final Color? labelColor;

  const AuraLogo({super.key, this.size = 48, this.showLabel = false, this.labelColor});

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      'assets/logo.svg',
      width: size,
      height: size,
    );

    if (!showLabel) return logo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 10),
        Text(
          'Aura',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: labelColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class AuraLogoSmall extends StatelessWidget {
  final double size;

  const AuraLogoSmall({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo.svg',
      width: size,
      height: size,
    );
  }
}
