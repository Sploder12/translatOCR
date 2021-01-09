import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'utility.dart';

void main() {
  runApp(DictationApp());
}

class DictationApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DictationAppState();
}

class DictationAppState extends State<DictationApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dictation App',
        home: DictationPage());
  }
}

class DictationPage extends StatefulWidget {
  const DictationPage({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DictationPageState();
}

class DictationPageState extends State<DictationPage> {
  SpeechToText speechToTextService;
  String transcript = "Tap to start";
  String previousTranscript = "";
  String lastWord = "";
  List<int> capitalizedWordsIndex = [];

  bool dictationStarted = false;



  Timer timer;
  dynamic pauseTime = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    speechToTextService = SpeechToText();
    timer = Timer.periodic(const Duration(seconds: 1), increasePauseTime);
    super.initState();

  }

  void increasePauseTime(_) {
    setState(() {
      pauseTime += 1;
      if (dictationStarted &&
          speechToTextService.isNotListening &&
          pauseTime < 7) {
        previousTranscript = transcript;
        capitalizedWordsIndex = [];
        startListening();
      }
      if (pauseTime >= 7) {
        transcript = transcript + lastWord;
        print("stopped");
        lastWord = "";
        speechToTextService.stop();
        timer.cancel();
      }
    });
  }

  void updateTranscript(result) {
    setState(() {
      transcript = previousTranscript + " " + result.recognizedWords;

      // find patterns
      //"Add period"; -> "."
      var words = transcript.split(" ");

      List<String> recognized = result.recognizedWords.split(" ");
      //recognizing new lines
      var lastTwo = words.sublist(words.length - 2).join(" ");

      if (lastTwo == "next line") {
        transcript =
            transcript.substring(0, transcript.length - lastTwo.length) + "\n";
      } else {
        lastWord = recognized.last;

        if ((lastWord == "capitalized" || lastWord == "capitalize") &&
            words.length > 1) {
          capitalizedWordsIndex.add(recognized.length - 2);
          for (int i in capitalizedWordsIndex) {
            String word = recognized[i];
            recognized[i] = recognized[i].capitalize();
          }
          recognized.removeWhere(
              (element) => element == 'capitalized' || element == 'capitalize');
          transcript = recognized.join(" ");
          lastWord = "";
        } else {
          transcript =
              transcript.substring(0, transcript.length - lastWord.length) +
                  " ";
        }
      }

      var sentences = transcript.split(".");
      for (int i = 0; i < sentences.length; ++i) {
        sentences[i] = sentences[i][0].toUpperCase() + sentences[i].substring(1);
      }

      transcript = sentences.join(". ");

      transcript = transcript.convertMathOperators({
        "times": "*",
        "divided by": "/",
        "plus": "+",
        "minus": "-"
      });
      if ((transcript + " " + lastWord).isUserTryingToCalculate()) {
        String expr = (transcript + " " + lastWord).findMathExpr();
        print("Extracted expression is: " + expr);
      }




      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void stopListening() {
    setState(() {
      dictationStarted = false;
    });
    speechToTextService.stop();
    timer.cancel();

    previousTranscript = "";
    transcript = "";
  }

  void updateOnPause(delta) {
    setState(() {
      pauseTime = 0;
    });
  }

  void startListening() async {
    await speechToTextService.listen(
        onResult: updateTranscript, onSoundLevelChange: updateOnPause);
  }

  void listenButtonPressed() async {
    if (!dictationStarted) {
      bool ready = await speechToTextService.initialize();

      if (ready) {
        setState(() {
          dictationStarted = true;
        });
        if (timer.isActive) {
          startListening();
        } else {
          timer = Timer.periodic(const Duration(seconds: 1), increasePauseTime);
          startListening();
        }
      }
    } else {
      stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dictation App"),
      ),
      body: Center(
          child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 32),
                  children: <TextSpan>[
                    TextSpan(
                        text: transcript,
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: lastWord, style: TextStyle(color: Colors.green)),
                  ],
                ),
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(dictationStarted ? Icons.mic : Icons.mic_off),
            onPressed: listenButtonPressed,
          ),
        ],
      ),
    );
  }
}
