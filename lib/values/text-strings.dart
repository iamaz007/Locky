import 'package:any_where_lock/models/lock.dart';

class TextStrings {
  static String appName = "Locky";
  static String emailField = "Email";
  static String passField = "Password";
  static String keyField = "Key";
  static String login = "Login";
  static String forgetPassword = "Forget Password";
  static String dontHaveAccnt = "Don\'t have an account?";
  static String haveAccnt = "Have an account?";
  static String register = "Register";
  static String goBack = "Back";
  static bool doorUnlocked = false;
  static String doorStatus = 'Locked';

  // global variables
  static String userEmail = '';
  static String userKey = '';
}
Lock lk = new Lock();