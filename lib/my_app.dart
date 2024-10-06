import 'package:bomber_man/providers/settings_provider.dart';
import 'package:bomber_man/screens/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(),
          lazy: false,
        ),
        // Provider(
        //   create: (context) => NakamaProvider(),
        //   dispose: (context, provider) => provider.dispose(),
        //   lazy: false,
        // ),
      ],
      child: MaterialApp(
        title: 'BomberMan',
        // theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //
        //   useMaterial3: true,
        // ),
        darkTheme: ThemeData.dark(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const MenuScreen(),
        // home: const SettingScreen(),
      ),
    );
  }
}
