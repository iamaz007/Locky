import 'package:any_where_lock/values/text-strings.dart';
import 'package:any_where_lock/values/ui-strings.dart';
import 'package:any_where_lock/widgets/auth_widgets/bezierContainer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:any_where_lock/main-screens/dashboard.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailFieldController = new TextEditingController();
  TextEditingController keyFieldController = new TextEditingController();
  TextEditingController passFieldController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;
  bool _success;
  String _userEmail;
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(border: InputBorder.none, fillColor: Color(0xfff3f3f4), filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () => signUpUser().then((value) async => {
            prefs = await SharedPreferences.getInstance(),
            prefs.setStringList('user', [_userEmail, keyFieldController.text]), // email, key
            saveInDb(emailFieldController.text).then((value) => {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashDemo())),
            }),
          }),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)],
            color: UiStrings.basecolor),
        child: Text(
          TextStrings.register,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(TextStrings.emailField, emailFieldController),
        _entryField(TextStrings.keyField, keyFieldController),
        _entryField(TextStrings.passField, passFieldController, isPassword: true),
      ],
    );
  }

  @override
  void dispose() {
    emailFieldController?.dispose();
    keyFieldController?.dispose();
    passFieldController?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(top: -height * .15, right: -MediaQuery.of(context).size.width * .4, child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  SizedBox(height: 50),
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
                  _submitButton(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    ));
  }

  Future signUpUser() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: emailFieldController.text,
      password: passFieldController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
    } else {
      _success = false;
    }
  }

  Future saveInDb(email) async{
    var id = await getUserLastId();
    print('last id: $id');
    FirebaseDatabase.instance.reference()
    .child("Users")
    .child(keyFieldController.text)
    .child("${id+1}")
    .update({"email": email});
  }

  final databaseReference = FirebaseDatabase.instance.reference();
  List userIds = new List();
  Future<int> getUserLastId() async{
    userIds = [];

    List keys = new List();;
    databaseReference.child('Users').child(keyFieldController.text).once().then((DataSnapshot snapshot) {
      // print(snapshot.value);
      keys = snapshot.value.keys.toList();
    }).then((value) {
      for (var i = 0; i < keys.length; i++) {
        if (keys[i] != 'temp') {
          userIds.add(keys[i]);
        }
      }
      // print(userIds);
    });
    return userIds.length > 0 ? userIds.last : 1;
  }
}
