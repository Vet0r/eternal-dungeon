class ArmorModel {
  final String id;
  final String name;
  final String description;
  final int defense;
  final int rarity;

  ArmorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.defense,
    required this.rarity,
  });

  factory ArmorModel.fromMap(String id, Map<String, dynamic> map) {
    return ArmorModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      defense: map['defense'] ?? 0,
      rarity: map['rarity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'defense': defense,
      'rarity': rarity,
    };
  }
}
