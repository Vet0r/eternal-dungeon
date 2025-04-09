import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void setPlayerOnlineWithDisconnect(int currentLevel) {
  String playerId = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("players_online/$playerId");
  ref.set({
    "name": FirebaseAuth.instance.currentUser!.displayName,
    "current_level": currentLevel,
    "last_active": ServerValue.timestamp,
  });
  ref.onDisconnect().remove();
}
