import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/generated/i18n.dart';
import 'package:flutter_treeview/tree_view.dart';

class UserInOutLogs extends StatefulWidget {
  const UserInOutLogs({Key key}) : super(key: key);

  @override
  _UserInOutLogsState createState() => _UserInOutLogsState();
}

class _UserInOutLogsState extends State<UserInOutLogs> {
  TextEditingController searchPerson = new TextEditingController();
  TreeViewController _treeViewController;
  void initState() {
    super.initState();
  }

  List daysReterived = [];
  searchDocument() {
    if (searchPerson.text != "") {
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child("FromHardware").child(searchPerson.text).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          // print('Data : ${snapshot.value}');
          List<Map<String, dynamic>> dummyListMap = new List();
          dummyListMap.add(Map<String, dynamic>.from(snapshot.value));
          generateTree(dummyListMap);
          // print(dummyListMap[0]);
        } else {
          print('not found');
        }
      });
    } else {
      print('write some thing');
    }
  }

  List<Node> nodes = [];
  generateTree(data) {
    var rng = new Random();
    nodes = [];
    var keys = data[0].keys.toList();
    print(keys);
    for (var i = 0; i < keys.length; i++) {
      nodes.add(Node(
        label: keys[i].toString(),
        key: keys[i].toString(),
        expanded: false,
        icon: Icons.folder_open,
        children: [
          if (data[0][keys[i]]['Day'] != null) 
            Node(label: "Day: ${data[0][keys[i]]['Day']}", key: 'd$i${rng.nextInt(100)}',),

          if (data[0][keys[i]]['Hour'] != null) 
            Node(label: "Hour: ${data[0][keys[i]]['Hour']}", key: 'd$i${rng.nextInt(100)}',),

          if (data[0][keys[i]]['Minute'] != null) 
            Node(label: "Minute: ${data[0][keys[i]]['Minute']}", key: 'd$i${rng.nextInt(100)}',),

          if (data[0][keys[i]]['Status'] != null) 
            Node(label: "Status: ${data[0][keys[i]]['Status']}", key: 'd$i${rng.nextInt(100)}',),

          if (data[0][keys[i]]['id'] != null) 
            Node(label: "Id: ${data[0][keys[i]]['id']}", key: 'd$i${rng.nextInt(100)}',),
        ],
      ));
    }
    setState(() {
      _treeViewController = TreeViewController(children: nodes);
    });
  }

  void loadDaysFromDb(data) {
    List keys = data[0].keys.toList();
    List days = [];
    for (var i = 0; i < keys.length; i++) {
      if (!days.contains(keys[i].split(':')[0])) {
        days.add(keys[i].split(':')[0]);
      }
    }

    // print(days);
    sortDays(days);
  }

  sortDays(days) {}

  // List<Node> nodes = [
  //   Node(
  //     label: 'Documents',
  //     key: 'docs',
  //     expanded: true,
  //     icon: Icons.folder_open,
  //     children: [
  //       Node(label: 'Job Search', key: 'd3', icon: Icons.input, children: [
  //         Node(
  //           label: 'Resume.docx',
  //           key: 'pd1',
  //           icon: Icons.insert_drive_file,
  //         ),
  //         Node(label: 'Cover Letter.docx', key: 'pd2', icon: Icons.insert_drive_file),
  //       ]),
  //     ],
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: searchDocument,
        child: Icon(Icons.search),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: "Search Person"),
                controller: searchPerson,
              ),
              SizedBox(
                height: 20,
              ),
              nodes.length > 0
                  ? Expanded(
                      child: TreeView(
                          controller: _treeViewController,
                          allowParentSelect: false,
                          supportParentDoubleTap: false,
                          // onExpansionChanged: _expandNodeHandler,
                          onNodeTap: (key) {
                            setState(() {
                              _treeViewController = _treeViewController.copyWith(selectedKey: key);
                            });
                          },
                          theme: treeViewTheme),
                    )
                  : Text('not loaded yet'),
            ],
          ),
        ),
      )),
    );
  }
}

TreeViewTheme treeViewTheme = TreeViewTheme(
  expanderTheme: ExpanderThemeData(
    type: ExpanderType.caret,
    modifier: ExpanderModifier.none,
    position: ExpanderPosition.start,
    color: Colors.black,
    size: 20,
  ),
  labelStyle: TextStyle(
    fontSize: 16,
    letterSpacing: 0.3,
  ),
  parentLabelStyle: TextStyle(
    fontSize: 16,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  ),
  iconTheme: IconThemeData(
    size: 18,
    color: Colors.black,
  ),
  colorScheme: ColorScheme.light(),
);
