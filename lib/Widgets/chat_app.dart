import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/CustomProvider/icon_image_provider.dart';

import '../Model/entry.dart';

class _ChatAppState extends State<ChatApp> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  Socket? socket;
  bool currentTheme = true;
  List<Entry> entries = [];

  Future<Socket> getSocket() async {
    if (socket == null) {
      Socket newSocket = await Socket.connect('192.168.178.27', 8124);
      print(
          'Connected to: ${newSocket.remoteAddress.address}:${newSocket.remotePort}');

      newSocket.listen(
        (Uint8List data) {
          String serverResponse;
          List<dynamic> entryList;
          try {
            serverResponse = String.fromCharCodes(data);
            entryList = jsonDecode(serverResponse);
          } catch (e) {
            print(e);
            print(String.fromCharCodes(data));
            return;
          }
          List<Entry> newEntries = [];
          for (var entry in entryList) {
            newEntries.add(Entry.fromJson(entry));
          }
          setState(() {
            entries = newEntries;
          });
        },
        onError: (error) {
          print(error);
          newSocket.destroy();
        },
        onDone: () {
          print('Server left.');
          newSocket.destroy();
        },
      );
      socket = newSocket;
      return socket!;
    } else {
      return socket!;
    }
  }

  sendMessage(String username) {
    if (_textController.text.isNotEmpty) {
      Entry entry = Entry(username, _textController.text);
      String jsonEntry = jsonEncode(entry);
      getSocket().then((socket) => socket.write(jsonEntry));
    }
  }

  scollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    getTheme();
    getSocket();
    super.initState();
  }

  getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool theme = (prefs.getBool('theme') ?? true);
    setState(() {
      currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Entry;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Center(
                  child: Row(
                    children: [
                      Text(
                        "Username: " + args.username,
                        textScaleFactor: 1.2,
                      ),
                      Switch(
                        value: currentTheme,
                        onChanged: (value) async {
                          await widget.changeTheme(value);
                          setState(() {
                            currentTheme = value;
                          });
                        },
                        thumbColor:
                            MaterialStateProperty.all(Colors.transparent),
                        trackColor: MaterialStateProperty.all(
                            const Color.fromRGBO(0, 0, 0, 0.2)),
                        inactiveThumbImage: IconImageProvider(Icons.light_mode,
                            scale: 0.96,
                            offSet: Offset.fromDirection(1, 1),
                            color: Theme.of(context).primaryColor),
                        activeThumbImage: IconImageProvider(
                          Icons.dark_mode,
                          scale: 0.96,
                          offSet: Offset.fromDirection(1, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        //alignment:new Alignment(x, y)
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 5,
                            shape: const BeveledRectangleBorder(
                              side: BorderSide(
                                color: Colors.transparent,
                                width: 0,
                              ),
                            ),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              itemCount: entries.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 30,
                                  child: Text(entries[index].username +
                                      ": " +
                                      entries[index].entry),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    endIndent: 20,
                    indent: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: "Your Message",
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      FloatingActionButton(
                        heroTag: "btn1",
                        onPressed: () {
                          sendMessage(args.username);
                        },
                        child: Icon(
                          Icons.send,
                          color: Theme.of(context).canvasColor,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 90,
            child: FloatingActionButton(
              heroTag: "btn2",
              mini: true,
              onPressed: () {
                scollDown();
              },
              child: Icon(
                Icons.arrow_downward_rounded,
                color: Theme.of(context).canvasColor,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatApp extends StatefulWidget {
  final Future<bool> Function(bool) changeTheme;

  const ChatApp({Key? key, required this.changeTheme}) : super(key: key);

  static const routeName = '/chat';

  @override
  State<StatefulWidget> createState() => _ChatAppState();
}
