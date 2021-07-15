import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiplication_trainer_app/backgrounds/audio_list_background.dart';
import 'package:flutter_multiplication_trainer_app/models/operation.dart';
import 'package:flutter_multiplication_trainer_app/preferences/shared_preferences.dart';
import 'package:flutter_multiplication_trainer_app/widgets/bottom_navbar.dart';

class AudioPage extends StatefulWidget {
  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final prefs = sharedPrefsService;
  late Operations operations;
  List<Operation> operationsList = [];
  List<dynamic> operationsJson = [];
  bool isPlayingForUI = false;

  @override
  void initState() {
    AudioService.playbackStateStream.listen((PlaybackState state) {
      if (state.playing) {}
      switch (state.processingState) {
        case AudioProcessingState.none:
          print('AudioServiceUI: none');
          break;
        case AudioProcessingState.connecting:
          print('AudioServiceUI: connecting');
          break;
        case AudioProcessingState.ready:
          print('AudioServiceUI: ready');
          break;
        case AudioProcessingState.buffering:
          print('AudioServiceUI: buffering');
          break;
        case AudioProcessingState.fastForwarding:
          print('AudioServiceUI: fastForwarding');
          break;
        case AudioProcessingState.rewinding:
          print('AudioServiceUI: rewinding');
          break;
        case AudioProcessingState.skippingToPrevious:
          print('AudioServiceUI: skippingToPrevious');
          break;
        case AudioProcessingState.skippingToNext:
          print('AudioServiceUI: skippingToNext');
          break;
        case AudioProcessingState.skippingToQueueItem:
          print('AudioServiceUI: skippingToQueueItem');
          break;
        case AudioProcessingState.completed:
          print('AudioServiceUI: completed');
          break;
        case AudioProcessingState.stopped:
          print('AudioServiceUI : stopped');
          isPlayingForUI = false;
          break;
        case AudioProcessingState.error:
          break;
      }
    });

    Random rnd;
    int min = prefs.minLimit;
    int max = prefs.maxLimit;
    int factor1 = 0;
    int factor2 = 0;
    int result = 0;
    int count = prefs.numOperations;

    for (int i = 0; i < count; i++) {
      rnd = new Random();

      factor1 = min + rnd.nextInt(max - min);
      factor2 = min + rnd.nextInt(max - min);
      result = factor1 * factor2;
      //print('$i : $factor1 $factor2 $result');
      Operation opTemp =
          new Operation(factor1: factor1, factor2: factor2, result: result);
      operationsList.add(opTemp);
      operationsJson.add(opTemp.toJson());
    }
    operations = Operations(operations: operationsList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Page'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListOperations(operationsList),
                ),
                BottomNavBar(),
              ],
            ),
            Positioned(
              child: Column(
                children: [
                  StreamBuilder<bool>(
                    stream: AudioService.playbackStateStream
                        .map((state) => state.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final playing = snapshot.data ?? false;

                      return Column(
                        children: [
                          // if (!playing)
                          //   PlayStopButton(
                          //       Operations(operations: operationsList)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (playing) pauseButton() else playButton(),
                              stopButton(),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              bottom: 200,
              right: 50,
            )
          ],
        ),
      ),
    );
  }

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: (isPlayingForUI)
            ? AudioService.play
            : () async {
                Map<String, dynamic> params = {
                  'Operations': operationsJson,
                  'Repetitions': 2
                };
                print(params);
                isPlayingForUI = true;
                await AudioService.connect();
                await AudioService.start(
                  backgroundTaskEntrypoint: textToSpeechTaskEntrypoint,
                  androidEnableQueue: true,
                  params: params,
                  // params: operations.toJson(),
                );
              },
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: () async {
          isPlayingForUI = false;
          await AudioService.stop();
          await AudioService.disconnect();
        },
      );
}

class PlayStopButton extends StatelessWidget {
  final Operations operations;
  PlayStopButton(this.operations);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: FloatingActionButton(
        elevation: 5,
        child: CircleAvatar(
          child: Icon(
            Icons.play_arrow,
            color: Colors.black,
          ),
          backgroundColor: Colors.transparent,
        ),
        onPressed: () async {
          // final mediaItem = MediaItem(
          //     id: '1', album: 'Numbers', title: 'Number 1', artist: '$result');

          await AudioService.connect();
          if (AudioService.running) {}
          await AudioService.start(
              backgroundTaskEntrypoint: textToSpeechTaskEntrypoint,
              androidEnableQueue: true,
              params: operations.toJson());
          // await AudioService.stop();
          // await AudioService.disconnect();
        },
      ),
    );
  }
}

class ListOperations extends StatelessWidget {
  final List<Operation> operations;
  ListOperations(this.operations);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: operations.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(
                  '${operations[index].factor1} X ${operations[index].factor2} =  ${operations[index].result}'));
        },
      ),
    );
  }
}
