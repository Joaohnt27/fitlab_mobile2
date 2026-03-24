import 'package:flutter/material.dart';

enum BadgeRarity { common, rare, epic, legendary }

class BadgeModel {
  final String id;
  final String name;
  final String icon;
  final BadgeRarity rarity;
  final bool isUnlocked;

  BadgeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    this.isUnlocked = false,
  });

  List<Color> get gradientColors {
    switch (rarity) {
      case BadgeRarity.legendary:
        return [Colors.yellow.shade600, Colors.orange.shade700];
      case BadgeRarity.epic:
        return [Colors.purple.shade600, Colors.pink.shade600];
      case BadgeRarity.rare:
        return [Colors.blue.shade600, Colors.cyan.shade600];
      case BadgeRarity.common:
        return [Colors.grey.shade600, Colors.grey.shade800];
    }
  }
}
