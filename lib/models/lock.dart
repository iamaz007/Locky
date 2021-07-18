import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Lock {
  final LocalAuthentication auth = LocalAuthentication();
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  String deviceId = 'Unknown';
  String doorStatus = 'locked';
  bool doorStat = false;
  FirebaseApp fapp;
  DatabaseReference messagesRef;
  StreamSubscription<Event> messagesSubscription;
  
  // functions

  Future<int> authenticate() async {
    bool authenticated = false;
    try {
      // setState(() {
      //   isAuthenticating = true;
      //   authorized = 'Authenticating';
      // });
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
      // setState(() {
      //   isAuthenticating = false;
      //   authorized = 'Authenticating';
      // });
    } on PlatformException catch (e) {
      print(e);
    }
    // if (!mounted) return;
    if (authenticated) {
      return 1;
    }
    else
    {
      return 0;
    }
    // final String message = authenticated ? 'Authorized' : 'Not Authorized';
    // setState(() {
    //   authorized = message;
    //   if (authenticated) {
        // FirebaseDatabase.instance
        //     .reference()
        //     .child("doorAuth")
        //     .update({_deviceId: 1});
    //   }
    // });
  }

  // get device id, this id will be used to identify in firebase
  Future getDeviceId() async {
    String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    // if (!mounted) return;

    // setState(() {
    //   deviceId = deviceId;
    //   print("deviceId->$_deviceId");
    // });
    return deviceId;
  }

  void cancelAuthentication() {
    auth.stopAuthentication();
  }

  Future readDoorStatus(String userKey) async{
    var db = await FirebaseDatabase.instance.reference().child("Home").child(userKey).child("door1").once();
    if (db.value == 1) {
      return 1;
    } else {
      return 0;
    }
  }
}