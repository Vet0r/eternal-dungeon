import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepseek/deepseek.dart';
import 'package:eternal_dungeon/game/utils/clear_json.dart';
import 'package:eternal_dungeon/game/utils/get_key.dart';

class GenerateNewEnemy {
  Future<Map<String, dynamic>> getLastEnemy() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('enemies')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    var doc = querySnapshot.docs.first;
    final data = doc.data();

    data.remove('created_at');
    return data;
  }

  Future<void> generateEnemy(
      int damage, int defense, int magickDefense, int hp, String lvl) async {
    String key = await getKey();

    Map<String, dynamic> lastEnemy = await getLastEnemy();
    DeepSeek deepSeek = DeepSeek(key);

    try {
      Completion response = await deepSeek.createChat(
        messages: [
          Message(
            role: "user",
            content:
                "Você é um gerador de inimigos para um jogo de RPG. Baseie o novo inimigo no seguinte inimigo já existente: ${jsonEncode(lastEnemy)}. O novo inimigo deve ser levemente mais interessante, mas mantenha os valores de dano (damage), defesa (defense), defesa mágica (magick_defense), e hp fixos. Gere um inimigo com os seguintes atributos: nome (name), descrição (description). A resposta deve ser estritamente um JSON com os campos: name (nome do inimigo), description (descrição detalhada). Não adicione nenhuma explicação, comentário ou texto extra fora do JSON. A resposta deve estar em português (PT-BR).",
          ),
        ],
        model: Models.chat.name,
        options: {
          "temperature": 1.0,
          "max_tokens": 4096,
        },
      );
      Map<String, dynamic> enemyData =
          jsonDecode(utf8.decode(cleanJson(response.text).runes.toList()));
      await FirebaseFirestore.instance.collection('enemies').doc(lvl).set(
        {
          'name': enemyData['name'],
          'description': enemyData['description'],
          'damage': damage,
          'defense': defense,
          'magick_defense': magickDefense,
          'hp': hp,
          'created_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on DeepSeekException catch (e) {
      print("API returned error: ${e.statusCode}:${e.message}");
    } catch (e) {
      print("Something unexpected happened: $e");
    }
  }
}
