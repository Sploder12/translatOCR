import 'dart:io';
import 'package:flutter/material.dart';

class DisplayTranslateScreen extends StatefulWidget {
  final String ttext;

  DisplayTranslateScreen(
      {Key key, @required this.ttext})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DisplayTranslateScreenState();
}


class DisplayTranslateScreenState extends State<DisplayTranslateScreen> {

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
                  "Results:",
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
                  (widget.ttext != "") ? widget.ttext:"NO OUTPUT DETECTED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: (widget.ttext != "") ? Colors.black: Colors.red
                  ),

                )
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
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