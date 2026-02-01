import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/track.dart';
import '../models/instrument.dart';

class TrackManager extends ChangeNotifier {
  final List<Track> _tracks = [];
  int _currentTrackIndex = -1;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  List<Track> get tracks => List.unmodifiable(_tracks);
  Track? get currentTrack => 
      _currentTrackIndex >= 0 && _currentTrackIndex < _tracks.length 
          ? _tracks[_currentTrackIndex] 
          : null;
  int get currentTrackIndex => _currentTrackIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  // Add a new track
  Track addTrack({
    String? name,
    Instrument instrument = Instrument.piano,
  }) {
    final trackNumber = _tracks.length + 1;
    final track = Track(
      name: name ?? 'Track $trackNumber',
      instrument: instrument,
    );
    _tracks.add(track);
    _currentTrackIndex = _tracks.length - 1;
    _updateTotalDuration();
    notifyListeners();
    return track;
  }

  // Remove a track
  void removeTrack(String trackId) {
    _tracks.removeWhere((t) => t.id == trackId);
    if (_currentTrackIndex >= _tracks.length) {
      _currentTrackIndex = _tracks.length - 1;
    }
    _updateTotalDuration();
    notifyListeners();
  }

  // Select a track
  void selectTrack(int index) {
    if (index >= -1 && index < _tracks.length) {
      _currentTrackIndex = index;
      notifyListeners();
    }
  }

  // Update track
  void updateTrack(String trackId, {
    String? name,
    Instrument? instrument,
    List<NoteEvent>? notes,
    double? volume,
    bool? isMuted,
    bool? isSolo,
    String? audioFilePath,
    Duration? duration,
  }) {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        name: name,
        instrument: instrument,
        notes: notes,
        volume: volume,
        isMuted: isMuted,
        isSolo: isSolo,
        audioFilePath: audioFilePath,
        duration: duration,
      );
      _updateTotalDuration();
      notifyListeners();
    }
  }

  // Toggle mute
  void toggleMute(String trackId) {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        isMuted: !_tracks[index].isMuted,
      );
      notifyListeners();
    }
  }

  // Toggle solo
  void toggleSolo(String trackId) {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        isSolo: !_tracks[index].isSolo,
      );
      notifyListeners();
    }
  }

  // Set track volume
  void setTrackVolume(String trackId, double volume) {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        volume: volume.clamp(0.0, 1.0),
      );
      notifyListeners();
    }
  }

  // Playback controls
  void play() {
    _isPlaying = true;
    notifyListeners();
    // Implement actual playback
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  void seek(Duration position) {
    _currentPosition = position;
    notifyListeners();
  }

  void _updateTotalDuration() {
    if (_tracks.isEmpty) {
      _totalDuration = Duration.zero;
    } else {
      _totalDuration = _tracks
          .map((t) => t.duration)
          .reduce((a, b) => a > b ? a : b);
    }
  }

  // Save project
  Future<String> saveProject(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final projectDir = Directory('${dir.path}/projects');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    final file = File('${projectDir.path}/$name.json');
    final data = {
      'name': name,
      'tracks': _tracks.map((t) => t.toJson()).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    };
    
    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  // Load project
  Future<void> loadProject(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      
      _tracks.clear();
      for (final trackData in data['tracks']) {
        _tracks.add(Track.fromJson(trackData));
      }
      
      _currentTrackIndex = _tracks.isNotEmpty ? 0 : -1;
      _updateTotalDuration();
      notifyListeners();
    }
  }

  // Clear all tracks
  void clearAll() {
    _tracks.clear();
    _currentTrackIndex = -1;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _isPlaying = false;
    notifyListeners();
  }
}
