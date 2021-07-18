import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:any_where_lock/models/update-lock.dart';
import 'package:platform_device_id/platform_device_id.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //variabales
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  String _deviceId = 'Unknown';
  String doorStatus = 'locked';
  bool doorStat = false;
  FirebaseApp fapp;
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _messagesSubscription;

  // functions
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
      if (authenticated) {
        FirebaseDatabase.instance
            .reference()
            .child("doorAuth")
            .update({_deviceId: 1});
      }
    });
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
    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
      print("deviceId->$_deviceId");
    });
    return deviceId;
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }

  // initing functions
  void initState() {
    super.initState();

    getDeviceId().then((value) {
      // after getting device id, we will work on firebase
      initDoorStatus(value);
    });

    // keep listening data changing in database
    dbInit().then((app) {
      fapp = app;
      final FirebaseDatabase database = FirebaseDatabase(app: fapp);
      _messagesRef = database.reference().child('doorAuth');
      database
          .reference()
          .child('doorAuth')
          // .child(_deviceId)
          // .equalTo(_deviceId)
          .once()
          .then((DataSnapshot snapshot) {
        print('Connected to second database and read ${snapshot.value}');
      });
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
      _messagesSubscription = _messagesRef.onChildChanged.listen((Event event) {
        print('Child update: ${event.snapshot.value}');
        setState(() {
          print(event.snapshot.value.runtimeType);
          if (event.snapshot.value == 0) {
            doorStatus = "locked";
            doorStat = false;
          } else {
            doorStatus = "unlocked";
            doorStat = true;
          }
        });
      }, onError: (Object o) {
        final DatabaseError error = o;
        print('Error: ${error.code} ${error.message}');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Auth Test'),
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Can check biometrics: $_canCheckBiometrics\n'),
                RaisedButton(
                  child: const Text('Check biometrics'),
                  onPressed: _checkBiometrics,
                ),
                Text('Available biometrics: $_availableBiometrics\n'),
                RaisedButton(
                  child: const Text('Get available biometrics'),
                  onPressed: _getAvailableBiometrics,
                ),
                Text('Current State: $doorStatus\n'),
                doorStat == false
                    ? RaisedButton(
                        child:
                            Text(_isAuthenticating ? 'Cancel' : 'Authenticate'),
                        onPressed: _isAuthenticating
                            ? _cancelAuthentication
                            : _authenticate,
                      )
                    : FlatButton(
                        onPressed: () {
                          getDeviceId().then((value) {
                            // after getting device id, we will work on firebase
                            updateDoorStatus(value);
                          });
                        },
                        child: Text(
                          doorStatus,
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.deepPurple,
                      ),
              ])),
    );
  }

  Future dbInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    final FirebaseApp app = await Firebase.initializeApp(
        // name: 'any-where-lock-default-rtdb',
        // options: Platform.isIOS || Platform.isMacOS
        //     ? FirebaseOptions(
        //         appId: '1:297855924061:ios:c6de2b69b03a5be8',
        //         apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
        //         projectId: 'flutter-firebase-plugins',
        //         messagingSenderId: '297855924061',
        //         databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
        //       )
        //     : FirebaseOptions(
        //         appId: '1:297855924061:android:669871c998cc21bd',
        //         apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
        //         messagingSenderId: '297855924061',
        //         projectId: 'flutter-firebase-plugins',
        //         databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
        //       ),
        );
    return app;
  }

  void initDoorStatus(id) async {
    // print(id);
    var db = await FirebaseDatabase.instance
        .reference()
        .child("doorAuth")
        .child(id)
        .once();

    if (!mounted) return;
    setState(() {
      print(db.value);
      if (db.value == 1) {
        doorStatus = "unlocked";
        doorStat = true;
        // FirebaseDatabase.instance.reference().child("doorAuth").update({id: 1});
      } else {
        doorStatus = "locked";
        doorStat = false;
        // FirebaseDatabase.instance.reference().child("doorAuth").update({id: 0});
      }
    });
  }

  void updateDoorStatus(id) async {
    FirebaseDatabase.instance.reference().child("doorAuth").update({id: 0});
    // print(id);
    // var db = await FirebaseDatabase.instance
    //     .reference()
    //     .child("doorAuth")
    //     .child(id)
    //     .once();

    // if (!mounted) return;
    // setState(() {
    //   print(db.value);
    //   if (db.value == 0) {
    //     doorStatus = "unlocked";
    //     doorStat = false;
    //     FirebaseDatabase.instance.reference().child("doorAuth").update({id: 1});
    //   } else {
    //     doorStatus = "locked";
    //     doorStat = true;
    //     FirebaseDatabase.instance.reference().child("doorAuth").update({id: 0});
    //   }
    // });
  }
}
