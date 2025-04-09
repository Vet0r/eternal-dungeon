import 'dart:math';

import 'package:eternal_dungeon/game/ai_powered_generators/generate_new_enemy.dart';
import 'package:eternal_dungeon/models/enemy.dart';
import 'package:eternal_dungeon/models/weapon_types.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eternal_dungeon/providers/player.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  final String levelId;
  final String playerId;
  GameScreen({required this.levelId, required this.playerId, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  late Enemy enemyData;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('levels')
        .doc(widget.levelId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs.map((doc) => doc.data()).toList();
      });
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    firebaseGetEnemyinstance(widget.levelId);
  }

  void attack() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    if (!playerProvider.isLoaded) return;

    final player = playerProvider.player!;
    final weapon = playerProvider.equippedWeapon!;
    final armor = playerProvider.equippedArmor;

    var enemyCollection = await FirebaseFirestore.instance
        .collection('levels')
        .doc(widget.levelId)
        .collection('enemys_instance')
        .get();

    var enemyDoc = enemyCollection.docs.first;
    enemyData = Enemy.fromMap(enemyDoc.data());

    final double playerDamage =
        ((weapon.isMagick ? player.intelligence * 0.4 : player.force * 0.4) *
                weapon.damage) -
            (weapon.isMagick ? enemyData.magickDefense : enemyData.defense);
    final double finalPlayerDamage = playerDamage > 0 ? playerDamage : 0;

    final int updatedEnemyHP =
        int.parse((enemyData.hp - finalPlayerDamage.round()).toString());
    await FirebaseFirestore.instance
        .collection('levels')
        .doc(widget.levelId)
        .collection('enemys_instance')
        .doc(enemyDoc.id)
        .update({'hp': updatedEnemyHP > 0 ? updatedEnemyHP : 0});

    await FirebaseFirestore.instance
        .collection('levels')
        .doc(widget.levelId)
        .collection('messages')
        .add({
      'message':
          "$player.name atacou com $weapon.name, causando $finalPlayerDamage de dano!",
      'time': FieldValue.serverTimestamp(),
    });

    final int equippedArmorDefense = armor?.defense ?? 0;
    ;
    final int equippedShieldDefense =
        weapon.type == WeaponType.defense ? weapon.damage : 0;
    final int totalDefense = equippedArmorDefense + equippedShieldDefense;
    final int enemyAttackDamage = enemyData.damage - totalDefense;
    final int finalEnemyAttackDamage =
        enemyAttackDamage > 0 ? enemyAttackDamage : 0;
    await FirebaseFirestore.instance
        .collection('levels')
        .doc(widget.levelId)
        .collection('messages')
        .add({
      'message':
          "${enemyData.name} atacou, causando ${enemyData.damage} de dano!",
      'time': FieldValue.serverTimestamp(),
    });
    print("Enemy attacked causing $finalEnemyAttackDamage damage!");
  }

  void defend() {
    // lógica de defesa
  }

  void usePotion() {
    // lógica de poção
  }

  void openInventory() {
    // abrir inventário
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eternal Dungeon")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black87,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        messages[index]['message'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3,
              children: [
                ElevatedButton(
                  onPressed: attack,
                  child: const Text("Atacar"),
                ),
                ElevatedButton(
                  onPressed: defend,
                  child: const Text("Defender"),
                ),
                ElevatedButton(
                  onPressed: usePotion,
                  child: const Text("Poção"),
                ),
                ElevatedButton(
                  onPressed: openInventory,
                  child: const Text("Inventário"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  firebaseGetEnemyinstance(String lvlid) {
    print(lvlid);
    FirebaseFirestore.instance
        .collection('levels')
        .doc(lvlid)
        .collection('enemys_instance')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        enemyData = Enemy.fromMap(snapshot.docs.first.data());
      } else {
        FirebaseFirestore.instance
            .collection('enemies')
            .doc(lvlid)
            .get()
            .then((doc) {
          if (doc.exists) {
            print("Enemy instance found");
            enemyData = Enemy.fromMap(doc.data()!);
            FirebaseFirestore.instance
                .collection('levels')
                .doc(lvlid)
                .collection('enemys_instance')
                .add(enemyData.toMap());
          } else {
            print("Enemy instance not found, generating new enemy");
            int lvlint = int.parse(lvlid) <= 0 ? 1 : int.parse(lvlid);
            GenerateNewEnemy().generateEnemy(
              int.parse(((1.5 * lvlint) + Random().nextInt(lvlint)).toString()),
              int.parse(((2 * lvlint) + Random().nextInt(lvlint)).toString()),
              int.parse(((2 * lvlint) + Random().nextInt(lvlint)).toString()),
              int.parse(
                ((1.8 * Random().nextInt(lvlint)) + Random().nextInt(lvlint))
                    .toString(),
              ),
              lvlint.toString(),
            );
          }
        });
      }
    });
  }
}
