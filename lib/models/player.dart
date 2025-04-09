class PlayerModel {
  final String id;
  final String name;
  final String email;
  final int currentLevel;
  final String equipedArmor;
  final String equipedWeapon;
  final int currentHealth;
  final int maxHealth;
  final int currentMana;
  final int maxMana;
  final int currentStamina;
  final int maxStamina;
  final int force;
  final int agility;
  final int intelligence;
  final bool isNew;

  PlayerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currentLevel,
    required this.equipedArmor,
    required this.equipedWeapon,
    required this.currentHealth,
    required this.maxHealth,
    required this.currentMana,
    required this.maxMana,
    required this.currentStamina,
    required this.maxStamina,
    required this.force,
    required this.agility,
    required this.intelligence,
    required this.isNew,
  });

  factory PlayerModel.fromMap(String id, Map<String, dynamic> map) {
    return PlayerModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      currentLevel: map['current_level'] ?? 1,
      equipedArmor: map['equiped_armor'] ?? '',
      equipedWeapon: map['equiped_weapon'] ?? '',
      currentHealth: map['current_health'] ?? 0,
      maxHealth: map['max_health'] ?? 0,
      currentMana: map['current_mana'] ?? 0,
      maxMana: map['max_mana'] ?? 0,
      currentStamina: map['current_stamina'] ?? 0,
      maxStamina: map['max_stamina'] ?? 0,
      force: map['force'] ?? 0,
      agility: map['agility'] ?? 0,
      intelligence: map['intelligence'] ?? 0,
      isNew: map['is_new'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'current_level': currentLevel,
      'equiped_armor': equipedArmor,
      'equiped_weapon': equipedWeapon,
      'current_health': currentHealth,
      'max_health': maxHealth,
      'current_mana': currentMana,
      'max_mana': maxMana,
      'current_stamina': currentStamina,
      'max_stamina': maxStamina,
      'force': force,
      'agility': agility,
      'intelligence': intelligence,
      'is_new': isNew,
    };
  }
}
