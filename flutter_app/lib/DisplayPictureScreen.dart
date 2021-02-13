import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutterapp/RecognizedTextPainter.dart';
import 'package:flutterapp/LanguageSelect.dart';
import 'BoundingBoxPainter.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Size imageSize;

  DisplayPictureScreen(
      {Key key, @required this.imagePath, @required this.imageSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<Rect> boxes = [];
  double scaleX = 1.0;
  double scaleY = 1.0;

  List<String> texts = [];
  List<Offset> positions = [];

  void redraw() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            CustomPaint(painter: BoundingBoxPainter(boxes)),
            CustomPaint(painter: RecognizedTextPainter(texts, positions)),
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
                final TextRecognizer cloudTextRecognizer =
                FirebaseVision.instance.cloudTextRecognizer();
                final FirebaseVisionImage currentImage =
                FirebaseVisionImage.fromFilePath(widget.imagePath);
                final VisionText result =
                await cloudTextRecognizer.processImage(currentImage);
                scaleX =
                    MediaQuery.of(context).size.width / widget.imageSize.width;
                scaleY = MediaQuery.of(context).size.height /
                    widget.imageSize.height;

                boxes = [];
                texts = [];
                positions = [];
                for (TextBlock block in result.blocks) {
                  var box = Rect.fromLTRB(block.boundingBox.left * scaleX, block.boundingBox.top * scaleY,
                      block.boundingBox.right * scaleX, block.boundingBox.bottom * scaleY);
                  boxes.add(box);
                  texts.add(block.text);
                  positions.add(Offset(box.left, box.top));

                }
                Navigator.push(
                    context,
                    Platform.isAndroid
                        ? MaterialPageRoute(
                        builder: (context) => DisplayLanguageScreen(
                          texts: texts
                        ))
                        : CupertinoPageRoute(
                        builder: (context) => DisplayLanguageScreen(
                            texts: texts
                        )));
                redraw();
              },
            ),
            FloatingActionButton(
              heroTag: 2,
              child: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
              onPressed: () {
                imageCache.clear();
                File(widget.imagePath).delete();
                Navigator.pop(context);
              },
            )
          ],
        ));
  }
}
