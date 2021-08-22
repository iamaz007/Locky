import 'package:any_where_lock/values/text-strings.dart';
import 'package:any_where_lock/values/ui-strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:any_where_lock/main-screens/dashboard_components/speech_api.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class DoorUnlockMethods extends StatefulWidget {
  @override
  _DoorUnlockMethodsState createState() => new _DoorUnlockMethodsState();
}

class _DoorUnlockMethodsState extends State<DoorUnlockMethods> {
  String text = 'Press the button and start speaking';
  bool isListening = false;
  // stt.SpeechToText speech = stt.SpeechToText();

  String userKey = "cv93121";
  void doorAction() async {
    var res = await lk.authenticate();
    print(res);

    if (res == 1) {
      if (TextStrings.doorUnlocked == true) {
        setState(() {
          TextStrings.doorUnlocked = false;
          UiStrings.doorBtnOpacity = 0;
          TextStrings.doorStatus = "Locked";

          FirebaseDatabase.instance.reference().child("Home").child(userKey).update({"door1": 0});
        });
      } else {
        setState(() {
          TextStrings.doorUnlocked = true;
          UiStrings.doorBtnOpacity = 0.7;
          TextStrings.doorStatus = "Unlocked";

          FirebaseDatabase.instance.reference().child("Home").child(userKey).update({"door1": 1});
        });
      }
    }
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                doorAction();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Finger Print',
                      style: TextStyle(fontSize: 20, fontFamily: 'Muli'),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                toggleRecording().then((value) {
                  print(this.text);
                  if (this.text == "open the door" || this.text == "open door") {
                    print('door opening');
                    FirebaseDatabase.instance.reference().child("Home").child(userKey).update({"door1": 1});
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.mic,
                    size: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Voice Detection',
                      style: TextStyle(fontSize: 20, fontFamily: 'Muli'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[],
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) {
          print("text: $text");
          if (text == "open the door" || text == "open door") {
            print('door opening');
            FirebaseDatabase.instance.reference().child("Home").child(userKey).update({"door1": 1});
            // FirebaseDatabase.instance.reference().child("Home").child(userKey).update({"door1": 0});
          }
          setState(() => this.text = text);
        },
        onListening: (isListening) {
          print('listening');

          setState(() => this.isListening = isListening);
          print("isListening: $isListening");
          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              // print(text);
              print(this.text);
            });
          }
        },
      );
}
