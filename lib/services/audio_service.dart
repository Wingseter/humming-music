import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/track.dart';
import '../models/instrument.dart';

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _isInitialized = false;
  double _currentPitch = 0;
  int _currentMidiNote = 0;
  String _currentNoteName = '';
  List<NoteEvent> _recordedNotes = [];
  DateTime? _recordingStartTime;
  
  // Getters
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  double get currentPitch => _currentPitch;
  int get currentMidiNote => _currentMidiNote;
  String get currentNoteName => _currentNoteName;
  List<NoteEvent> get recordedNotes => _recordedNotes;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _isInitialized = true;
      notifyListeners();
    } else {
      throw Exception('Microphone permission denied');
    }
  }

  Future<String> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/recording_$timestamp.m4a';

    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      _isRecording = true;
      _recordedNotes = [];
      _recordingStartTime = DateTime.now();
      
      // Start pitch detection simulation
      _startPitchDetection();
      
      notifyListeners();
      return path;
    }
    
    throw Exception('Recording permission not granted');
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    final path = await _recorder.stop();
    _isRecording = false;
    _currentPitch = 0;
    _currentMidiNote = 0;
    _currentNoteName = '';
    
    notifyListeners();
    return path;
  }

  void _startPitchDetection() {
    // In a real implementation, this would use actual pitch detection
    // For now, we simulate pitch detection
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Simulate pitch detection (replace with real implementation)
      _simulatePitchDetection();
    });
  }

  void _simulatePitchDetection() {
    // This is a placeholder - in real implementation, use pitch_detector package
    // or native audio processing
    
    // Simulate random pitch within human humming range (100-500 Hz)
    final random = Random();
    if (random.nextDouble() > 0.3) { // 70% chance of detecting a pitch
      _currentPitch = 150 + random.nextDouble() * 300;
      _currentMidiNote = frequencyToMidi(_currentPitch);
      _currentNoteName = midiToNoteName(_currentMidiNote);
      
      // Add note event
      if (_recordingStartTime != null) {
        final startTime = DateTime.now().difference(_recordingStartTime!);
        _recordedNotes.add(NoteEvent(
          midiNote: _currentMidiNote,
          frequency: _currentPitch,
          startTime: startTime,
          duration: const Duration(milliseconds: 50),
        ));
      }
    } else {
      _currentPitch = 0;
      _currentMidiNote = 0;
      _currentNoteName = '';
    }
    
    notifyListeners();
  }

  // Convert frequency to MIDI note number
  static int frequencyToMidi(double frequency) {
    if (frequency <= 0) return 0;
    // A4 = 440Hz = MIDI 69
    return (12 * (log(frequency / 440) / log(2)) + 69).round();
  }

  // Convert MIDI note to note name
  static String midiToNoteName(int midi) {
    if (midi <= 0) return '';
    const notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midi ~/ 12) - 1;
    final note = notes[midi % 12];
    return '$note$octave';
  }

  // Convert MIDI note to frequency
  static double midiToFrequency(int midi) {
    return 440 * pow(2, (midi - 69) / 12);
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}
