import 'package:any_where_lock/values/ui-strings.dart';
import 'package:flutter/material.dart';


import 'profile_components/components/body.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UiStrings.basecolor,
        title: Text("Profile"),
      ),
      body: Body(),
      
    );
  }
}
