import 'dart:async';

import 'package:any_where_lock/values/ui-strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BioMatricSettings extends StatefulWidget {
  const BioMatricSettings({Key key}) : super(key: key);

  @override
  _BioMatricSettingsState createState() => _BioMatricSettingsState();
}

class _BioMatricSettingsState extends State<BioMatricSettings> {
  Timer timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Outside'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseDatabase.instance.reference().update({"enroll_outside": 1});
                    timer = new Timer(const Duration(seconds: 2), () {
                      FirebaseDatabase.instance.reference().update({"enroll_outside": 0});
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)],
                        color: UiStrings.basecolor),
                    child: Text(
                      'EnRoll Outside',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseDatabase.instance.reference().update({"detect_outside": 1});
                    timer = new Timer(const Duration(seconds: 2), () {
                      FirebaseDatabase.instance.reference().update({"detect_outside": 0});
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)],
                        color: UiStrings.basecolor),
                    child: Text(
                      'Detect Outside',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Inside'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseDatabase.instance.reference().update({"enroll_inside": 1});
                    timer = new Timer(const Duration(seconds: 2), () {
                      FirebaseDatabase.instance.reference().update({"enroll_inside": 0});
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)],
                        color: UiStrings.basecolor),
                    child: Text(
                      'EnRoll Inside',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseDatabase.instance.reference().update({"detect_inside": 1});
                    timer = new Timer(const Duration(seconds: 2), () {
                      FirebaseDatabase.instance.reference().update({"detect_inside": 0});
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)],
                        color: UiStrings.basecolor),
                    child: Text(
                      'Detect Inside',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
