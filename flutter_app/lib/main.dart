import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CameraScreen.dart';

// Starting point of the app.
Future<void> main() async {
  // Ensure that plugin services are ready before app is run.
  WidgetsFlutterBinding.ensureInitialized();

  // Wait until all available cameras are retrieved.
  List<CameraDescription> cams = await availableCameras();

  // Runs the app based on platform.
  if (Platform.isAndroid) {
    runApp(MaterialApp(home: CameraScreen(cameras: cams)));
  } else if (Platform.isIOS) {
    runApp(CupertinoApp(home: CameraScreen(cameras: cams)));
  } else {
    // do nothing
  }
}
