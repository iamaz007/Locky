// this screen will contain users information of same house

import 'dart:convert';

import 'package:any_where_lock/values/ui-strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomeUsers extends StatefulWidget {
  const HomeUsers({Key key}) : super(key: key);

  @override
  _HomeUsersState createState() => _HomeUsersState();
}

class _HomeUsersState extends State<HomeUsers> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> getAllRecList = new List();
  List<Map<String, dynamic>> temp = new List();
  List userIds = new List();
  String userKey = 'cv93121';

  TextEditingController addUsername = new TextEditingController();
  TextEditingController addEmail = new TextEditingController();

  TextEditingController updateUsername = new TextEditingController();
  TextEditingController updateEmail = new TextEditingController();
  void initState() {
    super.initState();
    // loadData();
    getAllRec();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UiStrings.basecolor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Manage Family Member"),
        centerTitle: true,
      ),
      body: userIds.length > 0
          ? ListView.builder(
              itemCount: userIds.length,
              itemBuilder: (BuildContext ctxt, int index) {
                String email = temp[index][userIds[index]].containsKey('email') == false ? 'n/a' : temp[index][userIds[index]]['email'];
                String name = temp[index][userIds[index]].containsKey('name') == false ? 'n/a' : temp[index][userIds[index]]['name'];
                return GestureDetector(
                  onTap: () => updateExistUserInfo(ctxt, userIds[index], name, email),
                  child: Container(
                      child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Text("${userIds[index]}: $email"),
                  )),
                );
                // return new Text('test');
              })
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: UiStrings.basecolor,
        child: Icon(Icons.refresh),
        onPressed: () => getAllRec(),
      ),
    );
  }

  getAllRec() {
    temp = [];
    userIds = [];

    List keys = new List();
    var valueData;
    databaseReference.child('Users').child(userKey).once().then((DataSnapshot snapshot) {
      print(snapshot.value);
      keys = snapshot.value.keys.toList();
      valueData = snapshot.value;
    }).then((value) {
      // print(keys);
      // print(valueData);
      getAllRecList = [];
      for (var i = 0; i < keys.length; i++) {
        getAllRecList.add({keys[i]: valueData[keys[i]]});
        if (keys[i] != 'temp') {
          temp.add({keys[i]: valueData[keys[i]]});
          userIds.add(keys[i]);
        }
      }
    }).then((value) => {
          setState(() {}),
          loadData(),
          // print(temp[1]),
          // for (var i = 0; i < userIds.length; i++) {
          //   print(temp[i][userIds[i].toString()])
          // }
        });

    // print(temp);
  }

  loadData() {
    List fetchedRec = [];
    databaseReference.child('Users').child(userKey).onChildAdded.listen((Event event) {
      if (event.snapshot.key != 'temp') {
        fetchedRec.add(event.snapshot.key);

        if (fetchedRec.length >= getAllRecList.length) {
          // getLastRecords();
          updateNewUser(event.snapshot.key);
          // print(fetchedRec);
        }

        print("fetchedRec: ${fetchedRec.length}");
        print("getAllRecList: ${getAllRecList.length}");
        print('${event.snapshot.key}');
      }
    });
  }

  getLastRecords() {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('Users').child(userKey).limitToLast(1).once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        print(snapshot.value);
        // List<Map<String, dynamic>> dummyListMap = new List();
        // dummyListMap.add(Map<String, dynamic>.from(snapshot.value));

        
      } else {
        print('not found');
      }
    });
  }

  updateNewUser(id) {
    addUsername.text = '';
    addEmail.text = '';
    Alert(
        context: context,
        title: "$id Registeration",
        content: Column(
          children: <Widget>[
            TextField(
              controller: addEmail,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: addUsername,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'User Name',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              updateUserInfo(id, addUsername.text, addEmail.text);
              Navigator.pop(context);
            },
            child: Text(
              "Update",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  updateExistUserInfo(context, id, name, email) {
    updateUsername.text = name == 'n/a' ? '' : name;
    updateEmail.text = email == 'n/a' ? '' : email;
    // print(updateUsername.text);
    Alert(
        context: context,
        title: "$id Update",
        content: Column(
          children: <Widget>[
            TextField(
              controller: updateEmail,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: updateUsername,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'User Name',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              updateUserInfo(id, updateUsername.text, updateEmail.text);
              Navigator.pop(context);
            },
            child: Text(
              "Update",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  updateUserInfo(id, name, email) {
    databaseReference.child('Users').child(userKey).child(id).update({'name': name, 'email': email}).then((value) => getAllRec());
  }
}
