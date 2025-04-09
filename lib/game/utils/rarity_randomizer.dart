import 'dart:math';

int rarityRandomizer(int lvl) {
  int randrarity = Random().nextInt(100);
  randrarity = randrarity - lvl;
  switch (randrarity) {
    case (> 50):
      return 0;
    case (<= 50 && > 25):
      return 1;
    case (<= 25 && > 12):
      return 2;
    case (<= 12 && > 6):
      return 3;
    case (<= 6 && > 3):
      return 4;
    case (<= 3 && > 1):
      return 5;
    case (<= 1):
      return 6;
    default:
      return 0;
  }
}
