import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_project/Widgets/chat_app.dart';

import '../Model/entry.dart';

class _LoginState extends State<Login> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Please Enter your Name:"),
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Your Name",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if(_textController.text.isNotEmpty){
                  Navigator.pushNamed(
                      context,
                      ChatApp.routeName,
                      arguments: Entry(
                        _textController.text,
                        '',
                      )
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => _LoginState();
}
