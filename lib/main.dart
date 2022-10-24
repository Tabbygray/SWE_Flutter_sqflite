// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_initalize/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
                                onTap: () { //리스트 터치하면 textController에 터치한 내용 반영
                                  setState(() {
                                    if(selectedId == null){
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
        floatingActionButton: FloatingActionButton.extended( //액션버튼
          icon: Icon(Icons.save),
          onPressed: () async {
            selectedId != null // 선택된 리스트의 아이템이 존재하나요?
                ? await DatabaseHelper.instance.update( // 있으면 update
              Grocery(id: selectedId, name: textController.text),
            )
                :await DatabaseHelper.instance.add( // 없으면 ADD
              Grocery(name: textController.text),
            );
            setState(() {
              textController.clear();
              selectedId = null;
            });
          },
          label:Text('저장/갱신'),
        ),
      ),
    );
  }
}

class Grocery {
  final int? id;
  final String name;

  Grocery({this.id, required this.name});

  factory Grocery.fromMap(Map<String, dynamic> json) => new Grocery(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
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
    String path = join(documentsDirectory.path, 'groceries.db');
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
          name TEXT
      )
      ''');
  }

  Future<List<Grocery>> getGroceries() async {
    Database db = await instance.database;
    var groceries = await db.query('groceries', orderBy: 'name');
    List<Grocery> groceryList = groceries.isNotEmpty
        ? groceries.map((c) => Grocery.fromMap(c)).toList()
        : [];
    return groceryList;
  }

  Future<int> add(Grocery grocery) async { // 리스트에 아이템 추가
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }

  Future<int> remove(int id) async { // 리스트에서 아이템 제거 
    Database db = await instance.database;
    return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Grocery grocery) async { // 리스트 내용 업데이트
    Database db = await instance.database;
    return await db.update('groceries', grocery.toMap(),
        where: "id = ?", whereArgs: [grocery.id]);
  }
}
