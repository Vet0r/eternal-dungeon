import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getKey() async {
  DocumentSnapshot<Map<String, dynamic>> keyDoc = await FirebaseFirestore
      .instance
      .collection('misc')
      .doc('version')
      .collection('api')
      .doc('key')
      .get();
  String key = keyDoc.data()!['deep_seek'];
  return key;
}
