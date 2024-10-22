import 'package:bomber_man/screens/game/game_screen.dart';
import 'package:bomber_man/screens/lobby/lobby_screen.dart';
import 'package:bomber_man/screens/setting/setting_screen.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: IntrinsicWidth(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildButton('單機多人模式', () {
                  Navigator.of(context).push(GameScreen.route());
                }),
                const SizedBox(height: 16.0),
                buildButton('連線模式', () {
                  Navigator.of(context).push(LobbyScreen.route());
                }),
                const SizedBox(height: 16.0),
                buildButton('設定', () {
                  Navigator.of(context).push(SettingScreen.route());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        width: 300,
        decoration: ShapeDecoration(
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
          color: onTap == null ? Colors.grey : Colors.amber,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 36,
          vertical: 24,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            shadows: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 3,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
