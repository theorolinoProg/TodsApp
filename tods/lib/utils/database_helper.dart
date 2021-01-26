import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tods/models/tods.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todos.db';

    // Open/create the database at a given path
    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colDate TEXT)');
  }

  // Fetch Operation: Get all tods objects from database
  Future<List<Map<String, dynamic>>> getTodsMapList() async {
    Database db = await this.database;

    //		var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');
    var result = await db.query(todoTable, orderBy: '$colTitle ASC');
    return result;
  }

  // Insert Operation: Insert a tods object to database
  Future<int> insertTods(Tods tods) async {
    Database db = await this.database;
    var result = await db.insert(todoTable, tods.toMap());
    return result;
  }

  // Update Operation: Update a tods object and save it to database
  Future<int> updateTods(Tods tods) async {
    var db = await this.database;
    var result = await db.update(todoTable, tods.toMap(),
        where: '$colId = ?', whereArgs: [tods.id]);
    return result;
  }

  // Delete Operation: Delete a tods object from database
  Future<int> deleteTods(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
    return result;
  }

  // Get number of tods objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'tods List' [ List<Tods> ]
  Future<List<Tods>> getTodsList() async {
    var todoMapList = await getTodsMapList(); // Get 'Map List' from database
    int count =
        todoMapList.length; // Count the number of map entries in db table

    List<Tods> todoList = List<Tods>();
    // For loop to create a 'tods List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(Tods.fromMapObject(todoMapList[i]));
    }

    return todoList;
  }
}
