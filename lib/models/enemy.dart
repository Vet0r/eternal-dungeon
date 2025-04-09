class Enemy {
  final int damage;
  final int defense;
  final String description;
  final int magickDefense;
  final String name;
  final int hp;

  Enemy({
    required this.damage,
    required this.defense,
    required this.description,
    required this.magickDefense,
    required this.name,
    required this.hp,
  });

  factory Enemy.fromMap(Map<String, dynamic> map) {
    return Enemy(
      damage: map['damage'] ?? 0,
      defense: map['defense'] ?? 0,
      description: map['description'] ?? '',
      magickDefense: map['magick_defense'] ?? 0,
      name: map['name'] ?? '',
      hp: map['hp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'damage': damage,
      'defense': defense,
      'description': description,
      'magick_defense': magickDefense,
      'name': name,
      'hp': hp,
    };
  }
}
