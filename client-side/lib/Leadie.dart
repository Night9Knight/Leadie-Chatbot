import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:leadie/conversation_message.dart';
import 'package:http/http.dart' as http;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LeadieChatBot extends StatefulWidget {
  LeadieChatBot({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LeadieChatBotState createState() => new _LeadieChatBotState();
}

class _LeadieChatBotState extends State<LeadieChatBot> {
  final List<Facts> messageList = <Facts>[
    Facts(
      text:
          "Lastly, hopefully I am able to provide you a good guidance on what you need today", //Sample response before implement connection to Leadie
      name: "Leadie",
      type: false,
    ),
    Facts(
      text:
          "Also, please forgive me for any mistake made as I am still learning.", //Sample response before implement connection to Leadie
      name: "Leadie",
      type: false,
    ),
    Facts(
      text:
          "Hello there, I am Leadie, the Chatbot for USM CS Course Information. You may input your query either textually or verbally below. You are also suggested to build your query based on the suggestions given above the text field. ", //Sample response before implement connection to Leadie
      name: "Leadie",
      type: false,
    ),
  ];
  final TextEditingController _textController = new TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _isListening = false;
  String _speechStatus = "Long Press to Record";
  bool _hasConnection = false;

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Widget _queryInputWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        new Container(
          height: 44.0,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              OutlineButton(
                  child: Text("What is ..."),
                  onPressed: () {
                    _textController.clear();
                    _textController.text = "What is ...";
                  }),
              OutlineButton(
                  child: Text("Is ... major or elective"),
                  onPressed: () {
                    _textController.clear();
                    _textController.text = "Is ... major or elective";
                  }),
              OutlineButton(
                  child: Text("Any prerequisite for ..."),
                  onPressed: () {
                    _textController.clear();
                    _textController.text = "Any prerequisite for ...";
                  }),
              OutlineButton(
                  child: Text("Which semester offers ..."),
                  onPressed: () {
                    _textController.clear();
                    _textController.text = "Which semester offers ...";
                  }),
              OutlineButton(
                  child: Text("Describe ..."),
                  onPressed: () {
                    _textController.clear();
                    _textController.text = "Describe ...";
                  }),
            ],
          ),
        ),
        //Row(
        //children: <Widget>[
        Card(
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _submitQuery,
                    decoration:
                        InputDecoration.collapsed(hintText: "Send a message"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.green[400],
                      ),
                      onPressed: () => _submitQuery(_textController.text)),
                ),
              ],
            ),
          ),
        ),
        new Container(
          height: 44.0,
          margin: EdgeInsets.only(top: 4.0, bottom: 8.0),
          child: AvatarGlow(
            animate: _isListening,
            glowColor: Theme.of(context).primaryColor,
            endRadius: 75.0,
            duration: const Duration(milliseconds: 2000),
            repeatPauseDuration: const Duration(milliseconds: 100),
            repeat: true,
            child: new GestureDetector(
              onLongPressStart: (details) {
                if (_available && !_isListening) {
                  startListening();
                }
              },
              onLongPressEnd: (details) {
                if (_isListening) {
                  new Timer(const Duration(milliseconds: 1250),
                      () => stopListening());
                }
              },
              child: FloatingActionButton(
                onPressed: null,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
          ),
        ),
        new Container(
          height: 22.0,
          child: Center(
            child: new Text(_speechStatus),
          ),
        ),
        //],
        //),
      ],
    );
  }

  Future<void> initSpeechState() async {
    var available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
      },
      onError: (val) {
        print('onError: $val');
      },
    );

    if (!mounted) return;

    setState(() {
      _available = available;
    });
  }

  void startListening() {
    setState(() {
      _isListening = true;
      _speechStatus = "Listening";
    });
    _speech.listen(
        onResult: (val) => setState(() {
              _textController.text = val.recognizedWords;
              // if (val.hasConfidenceRating && val.confidence > 0) {
              //   _confidence = val.confidence;
              // }
            }),
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 5),
        //partialResults: false,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation);
  }

  void stopListening() {
    setState(() {
      _isListening = false;
      _speechStatus = "Long Press to Record";
    });
    _speech.stop();
  }

  void agentResponse(text) async {
    _textController.clear();
    try {
      var url =
          'https://leadie-csusm-cat300.herokuapp.com/'; // put link to leadie api
      String query = text;
      Map data = {"query": query};
      var body = jsonEncode(data);
      //print(body);
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      var status_code = response.statusCode;
      var bot_response;

      if (status_code == 201) {
        var bot_response_json = jsonDecode(response.body);
        bot_response = bot_response_json['response'];
      } else {
        bot_response = "Something is wrong, please try again.";
      }

      Facts message = Facts(
        text:
            bot_response, //Sample response before implement connection to Leadie
        name: "Leadie",
        type: false,
      );
      setState(() {
        messageList.insert(0, message);
      });
    } catch (e, stackTrace) {
      if (e is SocketException) {
        print("No Internet Connection");
        //Some callback function;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return new AlertDialog(
                title: new Text("You are disconnected to the Internet."),
                content: new Text("Please check your internet connection"),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        checkConnection();
                        if(_hasConnection) {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        }
                      },
                      child: new Text("OK"))
                ]);
          }),
        );
      }
    }
  }

  void _submitQuery(String text) {
    _textController.clear();
    Facts message = new Facts(
      text: text,
      name: "User",
      type: true,
    );
    setState(() {
      messageList.insert(0, message);
    });
    agentResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Leadie",
          style: TextStyle(color: Colors.green[400]),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Go back to home menu',
          color: Colors.green[400],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(children: <Widget>[
        Flexible(
            child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          reverse: true, //To keep the latest messages at the bottom
          itemBuilder: (_, int index) => messageList[index],
          itemCount: messageList.length,
        )),
        _queryInputWidget(context),
      ]),
    );
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _hasConnection = true;
      } else {
        _hasConnection = false;
      }
    } on SocketException catch(_) {
      _hasConnection = false;
    }
  }
}
