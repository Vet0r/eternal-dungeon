import 'package:eternal_dungeon/models/weapon.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeaponProvider with ChangeNotifier {
  final Map<String, WeaponModel> _weaponsCache = {};

  WeaponModel? getWeaponById(String id) => _weaponsCache[id];

  Future<WeaponModel?> fetchWeapon(String id) async {
    if (_weaponsCache.containsKey(id)) {
      return _weaponsCache[id];
    }

    final doc =
        await FirebaseFirestore.instance.collection('weapons').doc(id).get();

    if (!doc.exists) return null;

    final weapon = WeaponModel.fromMap(doc.id, doc.data()!);
    _weaponsCache[id] = weapon;
    notifyListeners();
    return weapon;
  }

  void clearCache() {
    _weaponsCache.clear();
    notifyListeners();
  }
}
