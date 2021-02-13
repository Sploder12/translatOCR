import 'dart:io';
import 'package:flutter/material.dart';

class DisplayLanguageScreen extends StatefulWidget {
  final List<String> texts;

  DisplayLanguageScreen(
      {Key key, @required this.texts})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DisplayLanguageScreenState();
}

final List<String> languages = ["English", "1", "2"];

class DisplayLanguageScreenState extends State<DisplayLanguageScreen> {
  String inValue = "English";
  String outValue = "English";
  void redraw() => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(

          children: <Widget>[
            Positioned(
                right: 40.0,
                top: 40.0,
              child: DropdownButton(
                value: inValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
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
            ),
        Positioned(
          left: 40.0,
          top: 40.0,
            child: DropdownButton(
              value: outValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
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
                //@TODO ADD FUNCTIONALITY
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
          ],
        ));
  }
}