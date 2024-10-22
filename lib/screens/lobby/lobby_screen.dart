import 'package:bomber_man/screens/lobby/guest_part_screen.dart';
import 'package:flutter/material.dart';

import 'host_part_screen.dart';


enum GameConnectProviderType {
  host,
  guest,
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      settings: const RouteSettings(
        name: 'Lobby',
      ),
      builder: (context) => const LobbyScreen(),
    );
  }

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {

  GameConnectProviderType? type;

  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if(didPop) {
            return;
          }

          if(type != null) {
            setState(() => type = null);
            return;
          }

          Navigator.of(context).pop(_);

        },
        child: switchContent(context),
      ),
    );
  }

  Widget switchContent(BuildContext context) {
    switch(type) {
      case GameConnectProviderType.host:
        return const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: HostPartScreen(),
          ),
        );
      case GameConnectProviderType.guest:
        return const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: GuestPartScreen(),
          ),
        );
      case null:
    }


    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Choose Mode'),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => setState(() => type = GameConnectProviderType.host),
              child: const Text('Host'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => setState(() => type = GameConnectProviderType.guest),
              child: const Text('Guest'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }

}
