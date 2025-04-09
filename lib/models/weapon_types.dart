enum WeaponType {
  damage,
  defense,
  heal;

  static WeaponType getTypeFromString(String type) {
    Map<String, WeaponType> types = {
      "damage": damage,
      "defense": defense,
      "heal": heal,
    };
    return types[type] ?? damage;
  }

  static String getStringFromType(WeaponType type) {
    Map<WeaponType, String> types = {
      damage: "damage",
      defense: "defense",
      heal: "heal",
    };
    return types[type] ?? "damage";
  }
}
