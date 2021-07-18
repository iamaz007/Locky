import 'package:any_where_lock/main-screens/biomatric_settings.dart';
import 'package:any_where_lock/main-screens/home-users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:any_where_lock/auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () => {},
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Settings",
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BioMatricSettings()));
            },
          ),
          ProfileMenu(
            text: "Manage Home Users",
            icon: "assets/icons/Plus Icon.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeUsers()));
            },
          ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons/Question mark.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () async {
              await _auth.signOut();
              prefs = await SharedPreferences.getInstance();
              if (prefs.containsKey('user')) {
                prefs.remove('user').then((value) => {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()))});
              }
              
            },
          ),
        ],
      ),
    );
  }
}
