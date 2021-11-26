import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_app.dart';
import 'login.dart';
import 'socket_test_widget.dart';

class Skeleton extends StatefulWidget {
  final MaterialColor primaryColor;

  const Skeleton({Key? key, required this.primaryColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  bool darkTheme = true;

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool theme = (prefs.getBool('theme') ?? true);
    return theme;
  }

  Future<bool> setTheme(bool theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("theme", theme);
    setState(() {
      darkTheme = theme;
    });
    return darkTheme;
  }

  @override
  void initState() {
    super.initState();
    getTheme().then((theme) => setTheme(theme));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        Login.routeName: (context) => const Login(),
        ChatApp.routeName: (context) => ChatApp(changeTheme: setTheme),
      },
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              brightness: darkTheme ? Brightness.dark : Brightness.light,
              primarySwatch: widget.primaryColor),
          primaryColor: widget.primaryColor),
    );
  }
}
