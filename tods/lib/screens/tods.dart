import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tods/models/tods.dart';
import 'package:tods/utils/database_helper.dart';
import 'package:intl/intl.dart';

class TodsDetail extends StatefulWidget {
  final String appBarTitle;
  final Tods tods;

  TodsDetail(this.tods, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TodsDetailState(this.tods, this.appBarTitle);
  }
}

class TodsDetailState extends State<TodsDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Tods tods;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  TodsDetailState(this.tods, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = tods.title;
    descriptionController.text = tods.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Update the title of tods object
  void updateTitle() {
    tods.title = titleController.text;
  }

  // Update the description of tods object
  void updateDescription() {
    tods.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    tods.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (tods.id != null) {
      // Case 1: Update operation
      result = await helper.updateTods(tods);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertTods(tods);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Tods Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Tods');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (tods.id == null) {
      _showAlertDialog('Status', 'No Tods was deleted');
      return;
    }

    int result = await helper.deleteTods(tods.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Tods Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Tods');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
