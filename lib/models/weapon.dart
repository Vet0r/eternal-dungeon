import 'package:eternal_dungeon/models/weapon_types.dart';

class WeaponModel {
  final String id;
  final String name;
  final WeaponType type;
  final String description;
  final int damage;
  final bool isMagick;
  final int rarity;

  WeaponModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.damage,
    required this.isMagick,
    required this.rarity,
  });

  factory WeaponModel.fromMap(String id, Map<String, dynamic> map) {
    return WeaponModel(
      id: id,
      name: map['name'] ?? '',
      type: WeaponType.getTypeFromString(map['type']),
      description: map['description'] ?? '',
      damage: map['damage'] ?? 0,
      isMagick: map['is_magick'] ?? false,
      rarity: map['rarity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'damage': damage,
      'is_magick': isMagick,
      'rarity': rarity,
    };
  }
}
