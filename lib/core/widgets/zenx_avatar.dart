import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/zenx_colors.dart';

class ZenXAvatar extends StatelessWidget {
  final double radius;
  final String? localImagePath;
  final String? networkImageUrl;

  const ZenXAvatar({
    super.key,
    this.radius = 50,
    this.localImagePath,
    this.networkImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (localImagePath != null && localImagePath!.isNotEmpty) {
      imageWidget = ClipOval(
        child: Image.file(
          File(localImagePath!),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      imageWidget = ClipOval(
        child: Image.network(
          networkImageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    } else {
      imageWidget = _buildFallback();
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ZenXColors.surfaceHighlight,
        border: Border.all(color: ZenXColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: ZenXColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: imageWidget,
    );
  }

  Widget _buildFallback() {
    return Icon(
      Icons.person,
      size: radius,
      color: ZenXColors.primary,
    );
  }
}
