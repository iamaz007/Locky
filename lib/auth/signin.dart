import 'package:any_where_lock/main-screens/dashboard.dart';
import 'package:any_where_lock/auth/signup.dart';
import 'package:any_where_lock/values/text-strings.dart';
import 'package:any_where_lock/values/ui-strings.dart';
import 'package:any_where_lock/widgets/auth_widgets/bezierContainer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailFieldController = new TextEditingController();
  TextEditingController keyFieldController = new TextEditingController();
  TextEditingController passFieldController = new TextEditingController();
  SharedPreferences prefs;

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
      onTap: () {
        userSignIn().then((value) async => {
          if (value == 1)
            {
              prefs = await SharedPreferences.getInstance(),
              prefs.setStringList('user', [emailFieldController.text, keyFieldController.text]).then((value) => {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashDemo())),
                  }), // email, key
            }
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
          TextStrings.login,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              TextStrings.dontHaveAccnt,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              TextStrings.register,
              style: TextStyle(color: UiStrings.basecolor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: TextStrings.appName,
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: UiStrings.basecolor,
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
                  _title(),
                  SizedBox(height: 50),
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
                  _submitButton(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: Text(TextStrings.forgetPassword, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: height * .055),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future userSignIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailFieldController.text, password: passFieldController.text);

      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('${user.email} signed in'),
      //   ),
      // );
      return 1;
    } on FirebaseAuthException catch (e) {
      print(e);
      // Scaffold.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Failed to sign in with Email & Password'),
      //   ),
      // );
      return 0;
    }
  }
}
