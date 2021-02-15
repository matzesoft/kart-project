import 'dart:async';
import 'package:kart_project/interfaces/cmd_interface.dart';

/// Path to the local audio files.
const String _AUDIO_PATH = "/home/pi/data/audio";

/// Lets you play audio which is locally saved on the Raspberry Pi.
class AudioProvider {
  final _cmdInterface = CmdInterface();
  bool _audioIsPlaying = false;

  /// Play a hoot sound.
  void playHootSound() {
    _playAudio('hoot.wav', Duration(milliseconds: 3000));
  }

  /// Plays the sound saved in the [_AUDIO_PATH] directory. Must be a `.wav` file.
  /// 
  /// Only allows playing audio if no audio is already playing (except Bluetooth
  /// streaming).
  void _playAudio(String file, Duration duration) {
    if (!_audioIsPlaying) {
      _audioIsPlaying = true;
      _cmdInterface.runCmd('aplay -q $_AUDIO_PATH/$file');
      Timer(duration, () => _audioIsPlaying = false);
    }
  }
}
