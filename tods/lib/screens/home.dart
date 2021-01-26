import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tods/models/tods.dart';
import 'package:tods/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tods/screens/tods.dart';

class TodsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodsListState();
  }
}

class TodsListState extends State<TodsList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Tods> todoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = <Tods>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Todss'),
      ),
      body: getTodsListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Tods('', '', ''), 'Add Tods');
        },
        tooltip: 'Add Tods',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getTodsListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: Text(getFirstLetter(this.todoList[position].title),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(this.todoList[position].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.todoList[position].description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  onTap: () {
                    _delete(context, todoList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.todoList[position], 'Edit Tods');
            },
          ),
        );
      },
    );
  }

  getFirstLetter(String title) {
    return title.substring(0, 2);
  }

  void _delete(BuildContext context, Tods tods) async {
    int result = await databaseHelper.deleteTods(tods.id);
    if (result != 0) {
      _showSnackBar(context, 'Tods Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  }

  void navigateToDetail(Tods tods, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodsDetail(tods, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Tods>> todoListFuture = databaseHelper.getTodsList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;
        });
      });
    });
  }
}
