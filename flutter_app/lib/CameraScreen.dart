import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'DisplayPictureScreen.dart';
import 'package:image_picker/image_picker.dart';

// Helper functions!
// `=>` is a shorthand for one-liner function.

bool isBackCamera(CameraDescription cam) =>
    cam.lensDirection == CameraLensDirection.back;

// A custom widget that shows camera preview in fullscreen.
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key key, @required this.cameras}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

// The internal state for a CameraScreen.
class CameraScreenState extends State<CameraScreen> {
  CameraDescription _backCamera;
  CameraController _controller;

  String _imageTaken = "";
  Size _imageSize = Size.zero;
  ResolutionPreset _qualityLevel = ResolutionPreset.medium;

  // Redraws everything in a CameraScreen.
  // `() {}` is a empty function that does nothing.
  void redraw() => setState(() {});

  // Locks device's orientation to normal portrait mode only
  void lockDeviceOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // Unlocks device's orientation
  void unlockDeviceOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void initState() {
    lockDeviceOrientation();

    super.initState();
    _backCamera = widget.cameras.firstWhere(isBackCamera);
    _controller = CameraController(_backCamera, _qualityLevel);
    _controller.initialize().then((_) {
      redraw();
    });
  }

  @override
  void dispose() {
    // Unlock device orientation when the widget is disposed.
    unlockDeviceOrientation();

    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getImageSize(String imagePath) async {
    final Completer<Size> completer = Completer<Size>();

    // Fetching image from path
    final Image image = Image.file(File(imagePath));

    // Retrieving its size
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size actualSize = await completer.future;
    setState(() {
      _imageSize = actualSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Scaffold(
          body: Transform.scale(
            scale: _controller.value.aspectRatio /
                MediaQuery.of(context).size.aspectRatio,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              ),
            ),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                heroTag: 1,
                child: ConstrainedBox(
                    constraints: BoxConstraints.expand(),
                    child: _imageTaken.isEmpty
                        ? Icon(Platform.isAndroid
                        ? Icons.photo
                        : CupertinoIcons.photo_camera_solid)
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_imageTaken),
                          fit: BoxFit.cover),
                    )),
                onPressed: () {
                  if (_imageTaken.isNotEmpty) {
                    _getImageSize(_imageTaken);
                    Navigator.push(
                        context,
                        Platform.isAndroid
                            ? MaterialPageRoute(
                            builder: (context) => DisplayPictureScreen(
                              imagePath: _imageTaken,
                              imageSize: _imageSize,
                            ))
                            : CupertinoPageRoute(
                            builder: (context) => DisplayPictureScreen(
                              imagePath: _imageTaken,
                              imageSize: _imageSize,
                            )));
                  }
                },
              ),
              FloatingActionButton(
                child: Icon(Platform.isAndroid
                    ? Icons.camera
                    : CupertinoIcons.circle_filled),
                heroTag: 2,
                onPressed: () async {
                  try {
                    // Generate a unique temporary path for image.
                    final imagePath = join((await getTemporaryDirectory()).path,
                        UniqueKey().toString() + '.png');

                    // Attempt to take a picture and log where it's been saved.
                    await _controller.takePicture(imagePath);
                    _imageTaken = imagePath;
                    redraw();
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
              ),
              FloatingActionButton(
                heroTag: 3,
                child: Icon(
                    Icons.photo),
                onPressed: () async {
                  try {
                    final imageFile = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    _imageTaken = imageFile.path;

                    redraw();
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
              )
            ],
          ));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

//
