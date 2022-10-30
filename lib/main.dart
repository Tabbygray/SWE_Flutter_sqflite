// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_initalize/main.dart';
import 'package:flutter_initalize/recipt_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as pathlib;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(SqliteApp());
}

class SqliteApp extends StatefulWidget {
  const SqliteApp({Key? key}) : super(key: key);

  @override
  State<SqliteApp> createState() => _SqliteAppState();
}

class _SqliteAppState extends State<SqliteApp> {
  int? selectedId;
  final textController = TextEditingController();
  final textController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: TextField(
          controller: textController,
        )),
        body: Center(
          child: FutureBuilder<List<Grocery>>(
              future: DatabaseHelper.instance.getGroceries(), // 로딩하고자 하는것
              builder: (BuildContext context, // 로딩전에 보이는것
                  AsyncSnapshot<List<Grocery>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text('Loading'));
                }
                return snapshot.data!.isEmpty
                    ? Center(child: Text('No Items in List'))
                    : ListView(
                        children: snapshot.data!.map((grocery) {
                          return Center(
                            child: Card(
                              color: selectedId == grocery.id // 선택한 list 색 회색으로
                                  ? Colors.white70
                                  : Colors.white,
                              child: ListTile(
                                title: Text(grocery.name),
                                onTap: () {
                                  //리스트 터치하면 textController에 터치한 내용 반영
                                  setState(() {
                                    if (selectedId == null) {
                                      textController.text = grocery.name;
                                      selectedId = grocery.id;
                                    } else {
                                      textController.text = '';
                                      selectedId = null;
                                    }
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    DatabaseHelper.instance.remove(grocery.id!);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
              }), // 서버에서 데이터 받아오기전 미리 render
        ),
        floatingActionButton: Builder(// context 해제용 builder
            builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                //액션버튼 1 -> 레시피보기
                icon: Icon(Icons.local_restaurant),
                onPressed: () async {
                  String reciptData = "";
                  String recipeName = "";
                  List<dynamic> jsonData =
                  await DatabaseHelper.instance.getlist();
                  for (int i = 0; i < jsonData.length; i++) {
                    if(jsonData[i]['id'] == selectedId) {
                      recipeName = jsonData[i]['name'];
                      reciptData = jsonData[i]['recipe'];
                    }
                  }
                  selectedId != null // 선택된 리스트의 아이템이 존재하나요?
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReciptScreen(recipeName,reciptData)),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("레시피를 선택해주세요!"),
                          duration: Duration(seconds: 2),
                          action: SnackBarAction(
                            label: "닫기",
                            onPressed: () {},
                          ),
                        ));
                  setState(() {
                    textController.clear();
                    selectedId = null;
                  });
                },
                backgroundColor: Colors.deepOrange,
                label: Text('레시피 보기'),
              ),
              FloatingActionButton.extended(
                //액션버튼 2 -> DB조작용
                icon: Icon(Icons.save),
                onPressed: () async {
                  selectedId != null // 선택된 리스트의 아이템이 존재하나요?
                      ? await DatabaseHelper.instance.update(
                          // 있으면 update
                          Grocery(
                              id: selectedId,
                              name: textController.text,
                              recipe: 'reci'),
                        )
                      : await DatabaseHelper.instance.add(
                          // 없으면 ADD
                          Grocery(name: textController.text, recipe: 'reci'),
                        );
                  setState(() {
                    textController.clear();
                    selectedId = null;
                  });
                },
                label: Text(''),
              ),
              FloatingActionButton(
                //액션버튼 3 -> DB 초기내용 가져오기용
                child: Icon(Icons.ramen_dining),
                onPressed: () async {
                  List<dynamic> jsonData =
                      await DatabaseHelper.instance.getlist();
                  for (int i = 0; i < jsonData.length; i++) {
                    await DatabaseHelper.instance.add(Grocery(
                        name: jsonData[i]['name'],
                        recipe: jsonData[i]['recipe']));
                  }
                  setState(() {
                    textController.clear();
                    selectedId = null;
                  });
                },
              ),
            ],
          );
        }),
      ),
    );
  } // end of build()
}

class Grocery {
  final int? id;
  final String name;
  final String recipe;

  Grocery({this.id, required this.name, required this.recipe});

  factory Grocery.fromMap(Map<String, dynamic> json) => new Grocery(
        id: json['id'],
        name: json['name'],
        recipe: json['recipe'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'recipe': recipe,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = pathlib.join(documentsDirectory.path, 'groceries.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groceries(
          id INTEGER PRIMARY KEY,
          name TEXT,
          recipe TEXT
      )
      ''');
  }

  Future<List<Grocery>> getGroceries() async { // DB 불러오기
    Database db = await instance.database;
    var groceries = await db.query('groceries', orderBy: 'name');
    List<Grocery> groceryList = groceries.isNotEmpty
        ? groceries.map((c) => Grocery.fromMap(c)).toList()
        : [];
    return groceryList;
  }

  Future<int> add(Grocery grocery) async {
    // 리스트에 아이템 추가
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }

  Future<int> remove(int id) async {
    // 리스트에서 아이템 제거
    Database db = await instance.database;
    return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Grocery grocery) async {
    // 리스트 내용 업데이트
    Database db = await instance.database;
    return await db.update('groceries', grocery.toMap(),
        where: "id = ?", whereArgs: [grocery.id]);
  }

  Grocery fromJson(Map<String, dynamic> json) {
    Grocery grocery = Grocery(name: json['name'], recipe: json['recipe']);
    return grocery;
  }

  Future<List<dynamic>> getlist() async {
    // Json String to List
    print('test');
    String jsonString = await loadAsset();
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  }

  Future<String> loadAsset() async {
    // 파일 읽어오기
    return await rootBundle.loadString('assets/main_recipe.json');
  }
}
