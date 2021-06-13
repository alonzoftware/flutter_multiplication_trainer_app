import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_session/audio_session.dart';

backgroundTaskEntrypoint() {
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

void textToSpeechTaskEntrypoint() async {
  AudioServiceBackground.run(() => TextPlayerTask());
}

/// This task defines logic for speaking a sequence of numbers using
/// text-to-speech.
class TextPlayerTask extends BackgroundAudioTask {
  int number = 3;
  Tts _tts = Tts();
  bool _finished = false;
  Sleeper _sleeper = Sleeper();
  Completer _completer = Completer();
  bool _interrupted = false;

  bool get _playing => AudioServiceBackground.state.playing;

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // flutter_tts resets the AVAudioSession category to playAndRecord and the
    // options to defaultToSpeaker whenever this background isolate is loaded,
    // so we need to set our preferred audio session configuration here after
    // that has happened.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Handle audio interruptions.
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (_playing) {
          onPause();
          _interrupted = true;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            if (!_playing && _interrupted) {
              onPlay();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
        _interrupted = false;
      }
    });
    // Handle unplugged headphones.
    session.becomingNoisyEventStream.listen((_) {
      if (_playing) onPause();
    });

    // Start playing.
    await _playPause();

    AudioServiceBackground.setMediaItem(mediaItem(number));
    AudioServiceBackground.androidForceEnableMediaButtons();
    try {
      await _tts.speak('$number');
      print('Index: $number');
      await _sleeper.sleep(Duration(milliseconds: 300));
    } catch (e) {
      // Speech was interrupted
    }
    // If we were just paused
    if (!_finished && !_playing) {
      try {
        // Wait to be unpaused
        await _sleeper.sleep();
      } catch (e) {
        // unpaused
      }
    }
    // for (var i = 1; i <= 10 && !_finished;) {
    //   AudioServiceBackground.setMediaItem(mediaItem(i));
    //   AudioServiceBackground.androidForceEnableMediaButtons();
    //   try {
    //     await _tts.speak('$i');
    //     print('Index: $i');
    //     i++;
    //     await _sleeper.sleep(Duration(milliseconds: 300));
    //   } catch (e) {
    //     // Speech was interrupted
    //   }
    //   // If we were just paused
    //   if (!_finished && !_playing) {
    //     try {
    //       // Wait to be unpaused
    //       await _sleeper.sleep();
    //     } catch (e) {
    //       // unpaused
    //     }
    //   }
    // }
    await AudioServiceBackground.setState(
      controls: [],
      processingState: AudioProcessingState.stopped,
      playing: false,
    );
    if (!_finished) {
      onStop();
    }
    _completer.complete();
  }

  @override
  Future<void> onPlay() => _playPause();

  @override
  Future<void> onPause() => _playPause();

  @override
  Future<void> onStop() async {
    // Signal the speech to stop
    _finished = true;
    _sleeper.interrupt();
    _tts.interrupt();
    // Wait for the speech to stop
    await _completer.future;
    // Shut down this task
    await super.onStop();
  }

  MediaItem mediaItem(int number) => MediaItem(
      id: 'tts_$number',
      album: 'Numbers',
      title: 'Number $number',
      artist: 'Sample Artist');

  Future<void> _playPause() async {
    if (_playing) {
      _interrupted = false;
      await AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        processingState: AudioProcessingState.ready,
        playing: false,
      );
      _sleeper.interrupt();
      _tts.interrupt();
    } else {
      final session = await AudioSession.instance;
      // flutter_tts doesn't activate the session, so we do it here. This
      // allows the app to stop other apps from playing audio while we are
      // playing audio.
      if (await session.setActive(true)) {
        // If we successfully activated the session, set the state to playing
        // and resume playback.
        await AudioServiceBackground.setState(
          controls: [MediaControl.pause, MediaControl.stop],
          processingState: AudioProcessingState.ready,
          playing: true,
        );
        _sleeper.interrupt();
      }
    }
  }
}

class Sleeper {
  Completer? _blockingCompleter;

  /// Sleep for a duration. If sleep is interrupted, a
  /// [SleeperInterruptedException] will be thrown.
  Future<void> sleep([Duration? duration]) async {
    _blockingCompleter = Completer();
    if (duration != null) {
      await Future.any([Future.delayed(duration), _blockingCompleter!.future]);
    } else {
      await _blockingCompleter!.future;
    }
    final interrupted = _blockingCompleter!.isCompleted;
    _blockingCompleter = null;
    if (interrupted) {
      throw SleeperInterruptedException();
    }
  }

  /// Interrupt any sleep that's underway.
  void interrupt() {
    if (_blockingCompleter?.isCompleted == false) {
      _blockingCompleter!.complete();
    }
  }
}

class SleeperInterruptedException {}

/// A wrapper around FlutterTts that makes it easier to wait for speech to
/// complete.
class Tts {
  final FlutterTts _flutterTts = new FlutterTts();
  Completer? _speechCompleter;
  bool _interruptRequested = false;
  bool _playing = false;

  Tts() {
    _flutterTts.setCompletionHandler(() {
      _speechCompleter?.complete();
    });
  }

  bool get playing => _playing;

  Future<void> speak(String text) async {
    _playing = true;
    if (!_interruptRequested) {
      _speechCompleter = Completer();
      await _flutterTts.speak(text);
      await _speechCompleter!.future;
      _speechCompleter = null;
    }
    _playing = false;
    if (_interruptRequested) {
      _interruptRequested = false;
      throw TtsInterruptedException();
    }
  }

  Future<void> stop() async {
    if (_playing) {
      await _flutterTts.stop();
      _speechCompleter?.complete();
    }
  }

  void interrupt() {
    if (_playing) {
      _interruptRequested = true;
      stop();
    }
  }
}

class TtsInterruptedException {}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration!) newPosition = mediaItem.duration!;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}
