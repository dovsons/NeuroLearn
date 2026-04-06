import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final _audioRecorder = Record();
  String? _recordingPath;

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> startRecording() async {
    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        return false;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '${dir.path}/$fileName';

      await _audioRecorder.start(
        path: _recordingPath!,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 16000,
      );

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final recordingPath = await _audioRecorder.stop();
      _recordingPath = recordingPath;
      return recordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  Future<File?> getRecordingFile() async {
    if (_recordingPath != null) {
      return File(_recordingPath!);
    }
    return null;
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
