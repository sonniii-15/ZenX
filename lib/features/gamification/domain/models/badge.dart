import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final DateTime dateEarned;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.dateEarned,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Badge && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
