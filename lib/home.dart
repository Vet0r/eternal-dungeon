import 'package:eternal_dungeon/game/create_new_char.dart';
import 'package:eternal_dungeon/game/game_screen.dart';
import 'package:eternal_dungeon/game/utils/set_online_player.dart';
import 'package:eternal_dungeon/models/player.dart';
import 'package:eternal_dungeon/providers/player.dart';
import 'package:eternal_dungeon/styles/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ETERNAL DUNGEON',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await Provider.of<PlayerProvider>(context, listen: false)
                      .loadPlayer(FirebaseAuth.instance.currentUser!.uid);
                  PlayerModel player =
                      Provider.of<PlayerProvider>(context, listen: false)
                          .player!;
                  if (player.isNew) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterCreationScreen(),
                      ),
                    );
                  } else {
                    setPlayerOnlineWithDisconnect(player.currentLevel);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          levelId: player.currentLevel.toString(),
                          playerId: player.id,
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Iniciar Aventura',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 40),
              logoutButton(context),
            ],
          ),
        ],
      ),
    );
  }

  logoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        backgroundColor: AppColors.secondaryButton,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () async {
        FirebaseAuth.instance.signOut();
        Provider.of<PlayerProvider>(context, listen: false).clearPlayer();
      },
      child: const Text(
        'Logout',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
