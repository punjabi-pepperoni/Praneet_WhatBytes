import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_auth_app/core/widgets/pressable_scale.dart';

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.color,
    this.iconColor,
    required this.onTap,
  }) : assert(icon != null || imagePath != null);

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: imagePath != null ? const EdgeInsets.all(15) : null,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                )
              : FaIcon(
                  icon!,
                  color: iconColor,
                  size: 30,
                ),
        ),
      ),
    );
  }
}
