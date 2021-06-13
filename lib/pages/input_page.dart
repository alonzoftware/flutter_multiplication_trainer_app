import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_multiplication_trainer_app/helpers/constants.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_button.dart';
import 'package:flutter_multiplication_trainer_app/widgets/reusable_card.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final prefs = sharedPrefsService;
  int factor1 = 0;
  int factor2 = 0;
  int result = 0;
  @override
  Widget build(BuildContext context) {
    factor1 = prefs.factor1;
    factor2 = prefs.factor2;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Multiplication Trainer'),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'settings');
                },
                icon: Icon(Icons.settings)),
          )
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: FactorCard(factor: factor1),
                    ),
                    Expanded(
                      flex: 1,
                      child: FactorCard(factor: factor2),
                    )
                  ],
                ),
                Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 55),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FactorCard(factor: result),
          ),
          BottomButton(
              text: 'GENERATE',
              color: Colors.blueAccent,
              onTap: generateFactor),
          BottomButton(text: 'RESULT', onTap: calculate),
        ],
      )),
    );
  }

  void generateFactor() {
    Random rnd;
    int min = prefs.minLimit;
    int max = prefs.maxLimit;
    rnd = new Random();

    factor1 = min + rnd.nextInt(max - min);
    factor2 = min + rnd.nextInt(max - min);
    prefs.factor1 = factor1;
    prefs.factor2 = factor2;
    result = 0;
    setState(() {});
    AudioService.stop();
  }

  void calculate() {
    setState(() {
      result = factor1 * factor2;
    });
    AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
  }
}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();
  //final _completer = Completer();

  // @override
  // Future<void> onStart(Map<String, dynamic>? params) async {
  //   // Connect to the URL
  //   await _audioPlayer.setUrl(
  //       "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3");
  //   //_audioPlayer.setAsset(assetPath)
  //   // Now we're ready to play
  //   _audioPlayer.play();
  // }
  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    final mediaItem = MediaItem(
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      album: "Foo",
      title: "Bar",
    );
    // Tell the UI and media notification what we're playing.
    AudioServiceBackground.setMediaItem(mediaItem);
    // Listen to state changes on the player...
    _audioPlayer.playerStateStream.listen((playerState) {
      // ... and forward them to all audio_service clients.
      AudioServiceBackground.setState(
        playing: playerState.playing,
        // Every state from the audio player gets mapped onto an audio_service state.
        processingState: {
          // ProcessingState.none: AudioProcessingState.none,
          ProcessingState.loading: AudioProcessingState.connecting,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState],
        // Tell clients what buttons/controls should be enabled in the
        // current state.
        controls: [
          playerState.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
      );
    });
    // Play when ready.
    _audioPlayer.play();
    // Start loading something (will play when ready).
    await _audioPlayer.setUrl(mediaItem.id);
  }

  @override
  Future<void> onStop() async {
    // Stop playing audio
    await _audioPlayer.stop();
    // Shut down this background task
    await super.onStop();
  }
}

// class AudioPlayerTask extends BackgroundAudioTask {
//   final _tts = FlutterTts();
//   bool _finished = false;
//   Completer _completer = Completer();

//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     // for (var n = 1; !_finished && n <= 10; n++) {
//     //   _tts.speak("$n");
//     //   await Future.delayed(Duration(seconds: 1));
//     // }

//     _tts.speak("${1245}");
//     _completer.complete();
//   }

//   @override
//   Future<void> onStop() async {
//     // Stop speaking the numbers
//     _finished = true;
//     // Wait for `onStart` to complete
//     await _completer.future;
//     // Now we're ready to let the isolate shut down
//     await super.onStop();
//   }
// }

class FactorCard extends StatelessWidget {
  const FactorCard({
    required this.factor,
  });

  final int factor;

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      onPress: () {},
      color: kActiveCardColor,
      cardChild: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Text((factor > 0) ? factor.toString() : '',
                style: kBigLabelTextStyle)),
      ),
    );
  }
}
