import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterapp/LangaugeTranslated.dart';
import 'package:translator/translator.dart';

class DisplayLanguageScreen extends StatefulWidget {
  final String texts;
  final translator = GoogleTranslator();
  DisplayLanguageScreen(
      {Key key, @required this.texts})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DisplayLanguageScreenState();
}

final List<String> languages = ["English", "Korean", "Spanish"];
final Map<String,String> langCodes = {"English":"en", "Korean":"ko", "Spanish":"es"};

class DisplayLanguageScreenState extends State<DisplayLanguageScreen> {
  String inValue = "English";
  String outValue = "English";
  void redraw() => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(

          children: <Widget>[
            Container(
              height: 690.0,
              width: 415.0,
              color: Color(0xff202020),
            ),
            Positioned(
              left: 20.0,
              top: 90.0,
              child: Container(
                height: 505.0,
                width: 372.5,
                decoration: BoxDecoration(
                  color: const Color(0xff6b6b70),
                    borderRadius: BorderRadius.circular(12)
                ),
              ),
            ),
            Positioned(
                left: 0.0,
                top: 55.0,
                width: 415.0,
                child: Text(
                  "Input:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.deepPurple
                  ),
                )
            ),
            Positioned(
                left: 25.0,
                top: 100.0,
                width: 365.0,
                child: Text(
                  (widget.texts != "") ? widget.texts:"NO INPUT DETECTED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: (widget.texts != "") ? Colors.black: Colors.red
                  ),

                )
            ),
            Positioned(
                left: 65.0,
                top: 30.0,
                child: Text(
                  "From:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepPurple
                  ),
                )
            ),
            Positioned(
                right: 85.0,
                top: 30.0,
                child: Text(
                  "To:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepPurple
                  ),
                )
            ),
            Positioned(
                right: 40.0,
                top: 40.0,
              child: DropdownButton(
                value: outValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    outValue = newValue;
                  });
                },
                items: languages
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value)
                  );
                }).toList(),
              )
            ),
        Positioned(
          left: 40.0,
          top: 40.0,
            child: DropdownButton(
              value: inValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.deepPurple
              ),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  inValue = newValue;
                });
              },
              items: languages
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
        )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 1,
              child: Icon(Icons.arrow_upward),
              onPressed: () async {
                try {
                  if(widget.texts != "") {
                    widget.translator.translate(
                        widget.texts, from: langCodes[inValue],
                        to: langCodes[outValue]).then((tStr) {
                      Navigator.push(
                          context,
                          Platform.isAndroid
                              ? MaterialPageRoute(
                              builder: (context) =>
                                  DisplayTranslateScreen(
                                      ttext: tStr.toString()
                                  ))
                              : CupertinoPageRoute(
                              builder: (context) =>
                                  DisplayTranslateScreen(
                                      ttext: tStr.toString()
                                  )));
                      //print(opt);
                    });
                  }
                } catch(err) {
                  //@TODO process errors such as not having the language
                  print(err);
                }
                redraw();
              },
            ),
            FloatingActionButton(
              heroTag: 2,
              child: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
              onPressed: () {

                Navigator.pop(context);
              },
            )
          ]
        ));
  }
}