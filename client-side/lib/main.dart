import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leadie/Leadie.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
        title: 'Leadie',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.green,
        ),
        home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Widget disconnected_alert_close = new AlertDialog(
      title: new Text("You are disconnected to the Internet."),
      content: new Text("Please check your internet connection"),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              exit(0);
            },
            child: new Text("Close"))
      ]
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
        StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext ctxt,
                AsyncSnapshot<ConnectivityResult> snapShot) {
              if (!snapShot.hasData) {
                return disconnected_alert_close;
              }
              var result = snapShot.data;
              switch (result) {
                case ConnectivityResult.none:
                  print("Disconnected");
                  return disconnected_alert_close;
                case ConnectivityResult.mobile:
                case ConnectivityResult.wifi:
                  print("Connected");
                  return MaterialApp(
                    home: Scaffold(
                        backgroundColor: Colors.tealAccent,
                        body: SafeArea(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Icon(
                                          MdiIcons.robot,
                                          size: 130,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(45),
                                          color: Color(0xffffc93c),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black, spreadRadius: 5),
                                          ],
                                        ),
                                      )),
                                  SizedBox(height: 30),
                                  Text("Leadie",
                                      style: TextStyle(
                                        fontFamily: 'Pacifico',
                                        fontSize: 45.0,
                                        color: Color(0xff07689f),
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Divider(
                                    color: Color(0xff0f4c75),
                                    thickness: 8,
                                    indent: 80,
                                    endIndent: 80,
                                  ),
                                  SizedBox(height: 35),
                                  Text("Leading your CS path",
                                      style: TextStyle(
                                        fontFamily: 'Garbata',
                                        fontSize: 22.0,
                                        color: Color(0xff8675a9),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      )),
                                  SizedBox(height: 20),
                                  Text("in USM",
                                      style: TextStyle(
                                        fontFamily: 'Garbata',
                                        fontSize: 22.0,
                                        color: Color(0xff8675a9),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      )),
                                  SizedBox(height: 50),
                                  RawMaterialButton(
                                    onPressed: (){
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return LeadieChatBot();
                                        }),
                                      );
                                    },
                                    elevation: 15.0,
                                    fillColor: Colors.lightGreenAccent,
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 80.0,
                                    ),
                                    padding: EdgeInsets.all(15.0),
                                    shape: CircleBorder(),
                                  ),
                                  SizedBox(height: 50),
                                  Row(children: <Widget>[
                                    Text("  ver 1.0.0",
                                        style: TextStyle(fontSize: 16.0, color: Colors.black)),
                                    Align(
                                      alignment: FractionalOffset.bottomCenter,
                                    )
                                  ]),
                                ]))),
                  );
                default:
                  return disconnected_alert_close;
              }
            })
        );
  }
}
