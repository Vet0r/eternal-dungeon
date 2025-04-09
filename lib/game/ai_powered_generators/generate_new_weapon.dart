import 'dart:convert';
import 'dart:math';
import 'package:eternal_dungeon/game/utils/clear_json.dart';
import 'package:eternal_dungeon/game/utils/get_key.dart';
import 'package:eternal_dungeon/game/utils/rarity_randomizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepseek/deepseek.dart';

class GenerateNewWeapon {
  Future<String> getNames() async {
    DocumentSnapshot<Map<String, dynamic>> keyDoc = await FirebaseFirestore
        .instance
        .collection('generated_names')
        .doc('weapons')
        .get();
    String names = keyDoc.data()!['names'];
    return names;
  }

  typeRandomizer() {
    int randtype = Random().nextInt(3);
    switch (randtype) {
      case 0:
        return "damage";
      case 1:
        return "defense";
      case 2:
        return "heal";
      default:
        return "damage";
    }
  }

  Future<void> generateWeapon(int lvl) async {
    int raridade = rarityRandomizer(lvl);
    String tipo = typeRandomizer();
    String key = await getKey();
    String names = await getNames();
    DeepSeek deepSeek = DeepSeek(key);
    try {
      Completion response = await deepSeek.createChat(
        messages: [
          Message(
            role: "user",
            content:
                "Você é um gerador de armas para um jogo de RPG. As armas podem ter três tipos: 'damage', 'defense' ou 'heal'. A raridade varia de 0 a 6, sendo 0 armas horíveis/objetos do dia a dia quebrados, até 6 sendo armas lendárias. Não adicione efeitos especiasi nas armas como fogo, congelar, nem habilidades especias, as armas somente irão dar dano, curar ou defender, nada alem disso. Não necessáriamente uma arma raridade 6 será magica e não necessáriamente uma arma lvl 0 não será mágica. Armas mágicas precisam ser objetos mágicos e laminas precisam ser não mágicos. Gere uma arma do tipo $tipo com raridade $raridade, incluindo os seguintes atributos: descrição, se é mágica (is_magick), nome, tipo e raridade. A resposta deve ser estritamente um JSON com os seguintes campos: name (nome da arma), type (tipo da arma), description (descrição detalhada), is_magick (booleano indicando se a arma é mágica), e rarity (nível de raridade). Não adicione nenhuma explicação, comentário ou texto extra fora do JSON. A resposta deve estar em português (PT-BR), nunca repita nomes, os nomes já usados são: $names, a unica coisa em ingles é o tipo da amra e o nome dos campos.",
          ),
        ],
        model: Models.chat.name,
        options: {
          "temperature": 1.0,
          "max_tokens": 4096,
        },
      );
      Map<String, dynamic> weaponData =
          jsonDecode(utf8.decode(cleanJson(response.text).runes.toList()));
      names = '$names, ${weaponData['name']}';
      await FirebaseFirestore.instance
          .collection('generated_names')
          .doc('weapons')
          .set(
        {
          'names': names,
        },
        SetOptions(merge: true),
      );
      int value = (1.2 * (lvl + 1) * (raridade + 1)).toInt();
      await FirebaseFirestore.instance.collection('weapons').doc().set(
        {
          weaponData['type']: value,
          'name': weaponData['name'],
          'type': weaponData['type'],
          'description': weaponData['description'],
          'is_magick': weaponData['is_magick'],
          'rarity': weaponData['rarity'],
        },
        SetOptions(merge: true),
      );
    } on DeepSeekException catch (e) {
      print("Api returned error: ${e.statusCode}:${e.message}");
    } catch (e) {
      print("something unexpected happened: $e");
    }
  }
}
