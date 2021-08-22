import 'package:any_where_lock/main-screens/analysis.dart';
import 'package:any_where_lock/main-screens/dashboard_components/doorUnlockMethods.dart';
import 'package:any_where_lock/main-screens/dashboard_components/utils.dart';
import 'package:any_where_lock/main-screens/profile_screen.dart';
import 'package:any_where_lock/main-screens/user-in-out-logs.dart';
import 'package:any_where_lock/models/lock.dart';

import 'package:any_where_lock/values/text-strings.dart';
import 'package:any_where_lock/values/ui-strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dashboard_components/custom_clipper.dart';

class DashDemo extends StatefulWidget {
  DashDemo({Key key}) : super(key: key);
  @override
  _DashDemoState createState() => _DashDemoState();
}

String userKey = "cv93121";

class _DashDemoState extends State<DashDemo> {
  

  String lastActivityMessage = 'loading...';
  

  void readDoorStatus() async {
    final FirebaseApp app = await Firebase.initializeApp();
    var res = await lk.readDoorStatus(userKey);

    if (!mounted) return;
    setState(() {
      print(res);
      if (res == 1) {
        TextStrings.doorUnlocked = true;
        UiStrings.doorBtnOpacity = 0.7;
        TextStrings.doorStatus = "Unlocked";
      } else {
        TextStrings.doorUnlocked = false;
        UiStrings.doorBtnOpacity = 0;
        TextStrings.doorStatus = "Locked";
      }
    });
  }

  void initState() {
    readDoorStatus();
    getRecentRecords();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    lk.messagesSubscription.cancel();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: bgColor,
        body: ListView(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              overflow: Overflow.visible,
              children: <Widget>[
                ClipPath(
                  clipper: MyCustomClipper(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                    height: 320,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: curveGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _topRow(context),
                        Text(TextStrings.appName, style: vpnStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FlatButton(
                                onPressed: () => {getRecentRecords()},
                                child: Icon(
                                  Icons.refresh,
                                  size: 30,
                                  color: Colors.white,
                                )),
                            Text(
                              'Download\n32 mb/s',
                              style: txtSpeedStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Positioned(
                    bottom: -screenWidth * 0.36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            // doorAction();
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return DoorUnlockMethods();
                                });
                          },
                          child: Container(
                            height: screenWidth * 0.51,
                            width: screenWidth * 0.51,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: curveGradient,
                              // color: Colors.red,
                            ),
                            child: Center(
                              child: Container(
                                height: screenWidth * 0.4,
                                width: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bgColor,
                                ),
                                child: Center(
                                  child: Container(
                                    height: screenWidth * 0.3,
                                    width: screenWidth * 0.3,
                                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: greenGradient, boxShadow: [
                                      BoxShadow(
                                        color: Color(0XFF00D58D).withOpacity(UiStrings.doorBtnOpacity),
                                        spreadRadius: 15,
                                        blurRadius: 15,
                                      ),
                                    ]),
                                    child: Center(
                                      child: Icon(TextStrings.doorUnlocked == true ? Icons.lock_open : Icons.lock_outline,
                                          color: Colors.white, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  // doorAction();
                  showDialog(
                      context: context,
                      builder: (_) {
                        return DoorUnlockMethods();
                      });
                },
                child: SizedBox(height: screenWidth * 0.40)),
            connectedStatusText(),
            SizedBox(height: 20),
            // We need to pass parameters to this widget
            locationCard('Last Activity', Colors.transparent, kenyaFlagUrl, lastActivityMessage, context),

            SizedBox(height: 20),
          ],
        ));
  }

  List dateKeys = new List();
  getRecentRecords() {
    FirebaseDatabase.instance.reference().child('Home').child(userKey).child('logs').once().then((DataSnapshot snapshot) {
      dateKeys = snapshot.value.keys.toList();
      getRecentActivity(snapshot.value, dateKeys, snapshot.value[dateKeys[dateKeys.length - 1]].keys.toList());
    });
  }

  getRecentActivity(var data, List days, List times) {
    // print(data);
    // print(times);
    times.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });
    print(times);
    String lastTime = times[times.length - 1];

    if (lastTime != '') {
      var userId = data[days[days.length - 1]][lastTime]['user'];

      FirebaseDatabase.instance.reference().child('Users').child(userKey).child(userId.toString()).once().then((DataSnapshot snapshot) {
        var userInfo = snapshot.value;
        if (data[days[days.length - 1]][lastTime]['activity'] == 'person_out') {
          setState(() {
            lastActivityMessage = "${userInfo['name']} close the door at $lastTime";
          });
        } else {
          setState(() {
            lastActivityMessage = "${userInfo['name']} opened the door at $lastTime";
          });
        }
      });
    }
    // print(lastTime);
  }
}

Widget _topRow(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: <Widget>[
              // Image.asset('assets/premiumcrown.png', height: 36),
              // SizedBox(width: 12),
              Icon(
                Icons.person,
                size: 26,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.tune,
            size: 26,
            color: Colors.white,
          ),
        ),
      )
    ],
  );
}

// Widget circularButtonWidget(BuildContext context, width) {
//   return
// }

Widget connectedStatusText() {
  return Align(
    alignment: Alignment.center,
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(text: 'Status :', style: connectedStyle, children: [
        TextSpan(text: ' ${TextStrings.doorStatus}\n', style: connectedGreenStyle),
        TextSpan(text: '00:22:45', style: connectedSubtitle),
      ]),
    ),
  );
}

Widget locationCard(title, cardBgColor, flag, country, context) {
  return InkWell(
    onTap: () async {
      await getLogDetails(context);
      // print(res);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => UserInOutLogs()));
      // Navigator.push(context, MaterialPageRoute(builder: (context) => VisualAndAnalysis(_createSampleData())));
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: locationTitleStyle),
          SizedBox(height: 14.0),
          Container(
            height: 80,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardBgColor,
              border: Border.all(
                color: Color(0XFF9BB1BD),
                style: BorderStyle.solid,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: ListTile(
                // leading: CircleAvatar(
                //   backgroundColor: Colors.transparent,
                //   radius: 20,
                //   backgroundImage: NetworkImage(flag),
                // ),
                title: Text(
                  country,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // trailing: Icon(
                //   Icons.refresh,
                //   size: 28,
                //   color: Colors.white70,
                // ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

getLogDetails(BuildContext context) {
  Map usersCount = new Map();
  FirebaseDatabase.instance.reference().child('Home').child(userKey).child('logs').once().then((DataSnapshot snapshot) {
    var origdata = snapshot.value;
    List days = origdata.keys.toList();
    for (var i = 0; i < days.length; i++) {
      List times = origdata[days[i]].keys.toList();
      for (var j = 0; j < times.length; j++) {
        if (origdata[days[i]][times[j]]['activity'] == 'person_in') {
          String userId = origdata[days[i]][times[j]]['user'].toString();
          List date = days[i].split('_');

          if (usersCount[userId] == null) {
            usersCount[userId] = [];
          } else {
            usersCount[userId].add({'date': "${date[0] + "-" + date[1] + "-" + date[2]}"});
          }
        }
      }
    }
    loadLogDetails(usersCount, context);
  });
}

loadLogDetails(var dataR, BuildContext context) {
  List<charts.Series<OrdinalSales, String>> activityIn = new List();
  List userIds = dataR.keys.toList();

  for (var i = 0; i < userIds.length; i++) {
    List dateExist = [];

    for (var j = 0; j < dataR[userIds[i]].length; j++) {
      if (dateExist.length <= 0) {
        dateExist.add({
          'date': dataR[userIds[i]][j]['date'],
          'totalActivity': 1,
        });
      } else {
        bool found = false;
        int foundedIndex = 0;
        for (var k = 0; k < dateExist.length; k++) {
          if (dateExist[k]['date'] == dataR[userIds[i]][j]['date']) {
            found = true;
            foundedIndex = k;
            break;
          }
        }
        if (found) {
          dateExist[foundedIndex]['totalActivity'] = dateExist[foundedIndex]['totalActivity'] + 1;
        } else {
          dateExist.add({
            'date': dataR[userIds[i]][j]['date'],
            'totalActivity': 1,
          });
        }
      }
    }
    // adding in activity_in
    List<OrdinalSales> temp = [];
    for (var l = 0; l < dateExist.length; l++) {
      temp.add(OrdinalSales(dateExist[l]['date'], dateExist[l]['totalActivity']));
    }
    activityIn.add(new charts.Series<OrdinalSales, String>(
      id: userIds[i].toString(),
      domainFn: (OrdinalSales sales, _) => sales.date,
      measureFn: (OrdinalSales sales, _) => sales.totalActivity,
      data: temp,
    ));
  }

  // print(temp);
  Navigator.push(context, MaterialPageRoute(builder: (context) => VisualAndAnalysis(activityIn)));
}

/// Create series list with multiple series
List<charts.Series<OrdinalSales, String>> _createSampleData() {
  final desktopSalesData = [
    new OrdinalSales('2014', 5),
    new OrdinalSales('2015', 25),
    new OrdinalSales('2016', 100),
    new OrdinalSales('2017', 75),
  ];

  final tableSalesData = [
    new OrdinalSales('2014', 25),
    new OrdinalSales('2015', 50),
    new OrdinalSales('2016', 10),
    new OrdinalSales('2017', 20),
  ];

  final mobileSalesData = [
    new OrdinalSales('2014', 10),
    new OrdinalSales('2015', 15),
    new OrdinalSales('2016', 50),
    new OrdinalSales('2017', 45),
  ];

  // return [
  //   new charts.Series<OrdinalSales, String>(
  //     id: 'Desktop',
  //     domainFn: (OrdinalSales sales, _) => sales.year,
  //     measureFn: (OrdinalSales sales, _) => sales.sales,
  //     data: desktopSalesData,
  //   ),
  //   new charts.Series<OrdinalSales, String>(
  //     id: 'Tablet',
  //     domainFn: (OrdinalSales sales, _) => sales.year,
  //     measureFn: (OrdinalSales sales, _) => sales.sales,
  //     data: tableSalesData,
  //   ),
  //   new charts.Series<OrdinalSales, String>(
  //     id: 'Mobile',
  //     domainFn: (OrdinalSales sales, _) => sales.year,
  //     measureFn: (OrdinalSales sales, _) => sales.sales,
  //     data: mobileSalesData,
  //   ),
  // ];
}

/// Sample ordinal data type.
class OrdinalSales {
  final String date;
  final int totalActivity;

  OrdinalSales(this.date, this.totalActivity);
}
