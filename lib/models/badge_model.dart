import 'dart:ui';

enum BadgeRarity { common, rare, epic, legendary }

class BadgeModel {
  final String id;
  final String name;
  final String icon;
  final BadgeRarity rarity;
  final bool isUnlocked;
  final String theme;
  final String requisito;

  BadgeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    this.isUnlocked = false,
    this.theme = 'Geral',
    this.requisito = 'Requisito não definido',
  });

  BadgeModel copyWith({bool? isUnlocked}) {
    return BadgeModel(
      id: id,
      name: name,
      icon: icon,
      rarity: rarity,
      theme: theme,
      requisito: requisito,
      isUnlocked:
          isUnlocked ?? this.isUnlocked, // Se não passar nada, mantém o atual
    );
  }

  List<Color> get gradientColors {
    switch (rarity) {
      case BadgeRarity.legendary:
        return const [Color(0xFFE6B800), Color(0xFFC65D00)];
      case BadgeRarity.epic:
        return const [Color(0xFF8E24AA), Color(0xFFC2185B)];
      case BadgeRarity.rare:
        return const [Color(0xFF1E88E5), Color(0xFF00ACC1)];
      case BadgeRarity.common:
        return const [Color(0xFF757575), Color(0xFF424242)];
    }
  }
}
