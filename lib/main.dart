import 'package:any_where_lock/auth/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:any_where_lock/values/text-strings.dart';
import 'package:any_where_lock/main-screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences prefs;
  bool userLogined = false;
  void initState() 
  {
    super.initState();
    checkUserSession().then((value) => {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userLogined == true ? DashDemo() :SignIn(),
    );
  }

  Future checkUserSession() async
  {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      List data = prefs.getStringList('user');
      TextStrings.userEmail = data[0];
      TextStrings.userKey = data[1];
      
      setState(() {
        userLogined = true;
      });
    }
  }
}
