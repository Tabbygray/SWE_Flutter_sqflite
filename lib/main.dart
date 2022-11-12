// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_initalize/recipt_screen.dart';
import 'package:flutter_initalize/search_by_name.dart';
import 'package:flutter_initalize/search_by_tags.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '푸로토타입'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(300, 80),
                  textStyle: const TextStyle(fontSize: 24),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SqliteApp())),
                child: Text("이름으로 검색")),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    fixedSize: const Size(300, 80),
                    textStyle: const TextStyle(fontSize: 24),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SqliteApp_Tags())),
                child: Text("태그로 검색")),
          ],
        ),
      ),
    );
  }
}
