import 'package:eternal_dungeon/models/armor.dart';
import 'package:eternal_dungeon/models/player.dart';
import 'package:eternal_dungeon/models/weapon.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProvider with ChangeNotifier {
  PlayerModel? _player;
  WeaponModel? _equippedWeapon;
  ArmorModel? _equippedArmor;

  PlayerModel? get player => _player;
  WeaponModel? get equippedWeapon => _equippedWeapon;
  ArmorModel? get equippedArmor => _equippedArmor;

  bool get isLoaded => _player != null;

  Future<void> loadPlayer(String playerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .get();

    if (doc.exists) {
      _player = PlayerModel.fromMap(doc.id, doc.data()!);
      notifyListeners();
      if (_player!.equipedWeapon.isNotEmpty) {
        await fetchWeapon(_player!.equipedWeapon);
      }
      if (_player!.equipedArmor.isNotEmpty) {
        await fetchArmor(_player!.equipedArmor);
      }
    }
  }

  Future<void> fetchWeapon(String weaponId) async {
    final doc = await FirebaseFirestore.instance
        .collection('weapons')
        .doc(weaponId)
        .get();

    if (doc.exists) {
      _equippedWeapon = WeaponModel.fromMap(doc.id, doc.data()!);
      notifyListeners();
    }
  }

  Future<void> fetchArmor(String armorid) async {
    final doc = await FirebaseFirestore.instance
        .collection('armors')
        .doc(armorid)
        .get();

    if (doc.exists) {
      _equippedArmor = ArmorModel.fromMap(doc.id, doc.data()!);
      notifyListeners();
    }
  }

  Future<void> updateField(Map<String, dynamic> values) async {
    if (_player == null) return;

    await FirebaseFirestore.instance
        .collection('players')
        .doc(_player!.id)
        .update(
          values,
        );

    final map = _player!.toMap();
    map.addAll(values);
    _player = PlayerModel.fromMap(_player!.id, map);
    notifyListeners();
  }

  Future<void> updatePlayer(PlayerModel updatedPlayer) async {
    await FirebaseFirestore.instance
        .collection('players')
        .doc(updatedPlayer.id)
        .set(updatedPlayer.toMap());

    _player = updatedPlayer;
    notifyListeners();
  }

  void clearPlayer() {
    _player = null;
    notifyListeners();
  }
}
