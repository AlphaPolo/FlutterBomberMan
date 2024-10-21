import 'package:bomber_man/screens/lobby/guest_row.dart';
import 'package:bomber_man/screens/lobby/network_key_config_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/peer_provider.dart';

class GuestPartScreen extends StatelessWidget {
  const GuestPartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PeerProvider(context),
          lazy: false,
        ),
        ListenableProvider(
          create: (context) => TextEditingController(),
        ),
      ],
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Guest'),
            const SizedBox(height: 12.0),
            Selector<PeerProvider, bool>(
              selector: (context, provider) => provider.connected,
              builder: (context, isConnected, child) {
                return Column(
                  children: [
                    Offstage(
                      offstage: isConnected,
                      child: IgnorePointer(
                        ignoring: isConnected,
                        child: child!,
                      ),
                    ),
                    if(isConnected)
                      const GuestRow(),
                    const SizedBox(height: 32.0),
                    const NetworkKeyConfigSelector(),
                  ],
                );

              },
              child: buildInputIdRow(),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputIdRow() {
    return Consumer<TextEditingController>(
      builder: (context, controller, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 250,
              ),
              child: TextField(controller: controller),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () {
                context.read<PeerProvider>().connect(context, controller.text);
              },
              child: const Text('Connect'),
            ),
          ],
        );
      }
    );
  }

}
