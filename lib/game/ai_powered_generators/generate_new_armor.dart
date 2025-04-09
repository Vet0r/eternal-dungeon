import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepseek/deepseek.dart';
import 'package:eternal_dungeon/game/utils/clear_json.dart';
import 'package:eternal_dungeon/game/utils/get_key.dart';
import 'package:eternal_dungeon/game/utils/rarity_randomizer.dart';

class GenerateNewArmor {
  Future<String> getNames() async {
    DocumentSnapshot<Map<String, dynamic>> keyDoc = await FirebaseFirestore
        .instance
        .collection('generated_names')
        .doc('armors')
        .get();
    String names = keyDoc.data()!['names'];
    return names;
  }

  Future<void> generateArmor(int lvl) async {
    int raridade = rarityRandomizer(lvl);
    String key = await getKey();
    String names = await getNames();
    DeepSeek deepSeek = DeepSeek(key);
    try {
      Completion response = await deepSeek.createChat(
        messages: [
          Message(
            role: "user",
            content:
                "Você é um gerador de armaduras para um jogo de RPG. A raridade varia de 0 a 6, sendo 0 armaduras horríveis/objetos do dia a dia quebrados, até 6 sendo armaduras lendárias. Gere uma armadura com raridade $raridade, incluindo os seguintes atributos: descrição, nome, defesa (defense) e raridade. A resposta deve ser estritamente um JSON com os seguintes campos: name (nome da armadura), description (descrição detalhada), defense (valor de defesa), e rarity (nível de raridade). Não adicione nenhuma explicação, comentário ou texto extra fora do JSON. A resposta deve estar em português (PT-BR), nunca repita nomes, os nomes já usados são: $names.",
          ),
        ],
        model: Models.chat.name,
        options: {
          "temperature": 1.0,
          "max_tokens": 4096,
        },
      );
      Map<String, dynamic> armorData =
          jsonDecode(utf8.decode(cleanJson(response.text).runes.toList()));
      names = '$names, ${armorData['name']}';
      await FirebaseFirestore.instance
          .collection('generated_names')
          .doc('armors')
          .set(
        {
          'names': names,
        },
        SetOptions(merge: true),
      );
      int value = (1.2 * (lvl + 1) * (raridade + 1)).toInt();
      await FirebaseFirestore.instance.collection('armors').doc().set(
        {
          'defense': value,
          'name': armorData['name'],
          'description': armorData['description'],
          'rarity': armorData['rarity'],
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
