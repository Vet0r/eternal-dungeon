import 'package:eternal_dungeon/game/game_screen.dart';
import 'package:eternal_dungeon/providers/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  int totalPoints = 5;
  int force = 0;
  int agility = 0;
  int intelligence = 0;

  int get remainingPoints => totalPoints - force - agility - intelligence;

  int get maxHealth => 10 + ((force * 0.8).toInt() + (agility * 0.5).toInt());
  int get maxStamina => 8 + (agility * 2).toInt() - (force * 0.5).toInt();
  int get maxMana => 8 + (intelligence * 2).toInt() - (force * 0.5).toInt();

  String? selectedWeapon;
  String? selectedArmor;

  List<Map<String, dynamic>>? cachedWeapons;
  List<Map<String, dynamic>>? cachedArmors;

  void increment(String attr) {
    if (remainingPoints > 0) {
      setState(() {
        if (attr == 'force') force++;
        if (attr == 'agility') agility++;
        if (attr == 'intelligence') intelligence++;
      });
    }
  }

  void decrement(String attr) {
    setState(() {
      if (attr == 'force' && force > 0) force--;
      if (attr == 'agility' && agility > 0) agility--;
      if (attr == 'intelligence' && intelligence > 0) intelligence--;
    });
  }

  void onConfirm() async {
    if (remainingPoints != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Distribua todos os pontos antes de continuar."),
        ),
      );
      return;
    }
    if (selectedArmor == null || selectedWeapon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Slecione uma arma e armadura inicial."),
        ),
      );
      return;
    }
    Map<String, dynamic> values = {
      "force": force,
      "agility": agility,
      "intelligence": intelligence,
      "max_health": maxHealth,
      "max_stamina": maxStamina,
      "max_mana": maxMana,
      "equiped_weapon": selectedWeapon,
      "equiped_armor": selectedArmor,
      "is_new": false,
    };
    Provider.of<PlayerProvider>(context, listen: false).updateField(values);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          levelId: Provider.of<PlayerProvider>(context, listen: false)
              .player!
              .currentLevel
              .toString(),
          playerId:
              Provider.of<PlayerProvider>(context, listen: false).player!.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Criação de Personagem"),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Distribua seus pontos (restantes: $remainingPoints)",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              buildAttributeRow("Força", force, () => increment("force"),
                  () => decrement("force")),
              buildAttributeRow("Agilidade", agility,
                  () => increment("agility"), () => decrement("agility")),
              buildAttributeRow(
                  "Inteligência",
                  intelligence,
                  () => increment("intelligence"),
                  () => decrement("intelligence")),
              const SizedBox(height: 30),
              const Divider(color: Colors.white),
              const SizedBox(height: 10),
              Text("HP Máximo: $maxHealth",
                  style: const TextStyle(color: Colors.white)),
              Text("Stamina Máxima: $maxStamina",
                  style: const TextStyle(color: Colors.white)),
              Text("Mana Máxima: $maxMana",
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 30),
              Text("Escolha sua arma inicial",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              buildWeaponOption(),
              const SizedBox(height: 30),
              Text("Escolha sua armadura inicial",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              buildArmorOption(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  remainingPoints == 0 ? onConfirm() : null;
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Confirmar Personagem"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAttributeRow(
      String label, int value, VoidCallback onAdd, VoidCallback onRemove) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Row(
          children: [
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            ),
            Text("$value",
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            ),
          ],
        )
      ],
    );
  }

  Widget buildWeaponOption() {
    if (cachedWeapons != null) {
      return buildWeaponList(cachedWeapons!);
    }

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('weapons')
          .where(FieldPath.documentId, whereIn: ['0', '1']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Erro ao carregar armas",
              style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Nenhuma arma encontrada",
              style: TextStyle(color: Colors.white));
        }

        cachedWeapons = snapshot.data!.docs
            .map((doc) => {"id": doc.id, ...doc.data()})
            .toList();

        return buildWeaponList(cachedWeapons!);
      },
    );
  }

  Widget buildWeaponList(List<Map<String, dynamic>> weapons) {
    return Column(
      children: weapons.map((weapon) {
        return ListTile(
          title: Text(weapon['name'] ?? 'Sem nome',
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "Descrição: ${weapon['description'] ?? 'Sem descrição'}\n"
            "Dano: ${weapon['damage'] ?? 'Desconhecido'}",
            style: const TextStyle(color: Colors.white70),
          ),
          leading: Radio<String>(
            value: weapon['id'],
            groupValue: selectedWeapon,
            onChanged: (value) {
              setState(() {
                selectedWeapon = value;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget buildArmorOption() {
    if (cachedArmors != null) {
      return buildArmorList(cachedArmors!);
    }

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('armors')
          .where(FieldPath.documentId, whereIn: ['0', '1']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Erro ao carregar armaduras",
              style: TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Nenhuma armadura encontrada",
              style: TextStyle(color: Colors.white));
        }

        cachedArmors = snapshot.data!.docs
            .map((doc) => {"id": doc.id, ...doc.data()})
            .toList();

        return buildArmorList(cachedArmors!);
      },
    );
  }

  Widget buildArmorList(List<Map<String, dynamic>> armors) {
    return Column(
      children: armors.map((armor) {
        return ListTile(
          title: Text(armor['name'] ?? 'Sem nome',
              style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "Descrição: ${armor['description'] ?? 'Sem descrição'}\n"
            "Defesa: ${armor['defense'] ?? 'Desconhecida'}",
            style: const TextStyle(color: Colors.white70),
          ),
          leading: Radio<String>(
            value: armor['id'],
            groupValue: selectedArmor,
            onChanged: (value) {
              setState(() {
                selectedArmor = value;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
