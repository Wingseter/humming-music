import 'package:uuid/uuid.dart';
import 'instrument.dart';

class Track {
  final String id;
  String name;
  Instrument instrument;
  List<NoteEvent> notes;
  double volume;
  bool isMuted;
  bool isSolo;
  String? audioFilePath;
  Duration duration;

  Track({
    String? id,
    required this.name,
    required this.instrument,
    List<NoteEvent>? notes,
    this.volume = 1.0,
    this.isMuted = false,
    this.isSolo = false,
    this.audioFilePath,
    this.duration = Duration.zero,
  })  : id = id ?? const Uuid().v4(),
        notes = notes ?? [];

  Track copyWith({
    String? name,
    Instrument? instrument,
    List<NoteEvent>? notes,
    double? volume,
    bool? isMuted,
    bool? isSolo,
    String? audioFilePath,
    Duration? duration,
  }) {
    return Track(
      id: id,
      name: name ?? this.name,
      instrument: instrument ?? this.instrument,
      notes: notes ?? this.notes,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isSolo: isSolo ?? this.isSolo,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instrument': instrument.name,
        'notes': notes.map((n) => n.toJson()).toList(),
        'volume': volume,
        'isMuted': isMuted,
        'isSolo': isSolo,
        'audioFilePath': audioFilePath,
        'durationMs': duration.inMilliseconds,
      };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'],
        name: json['name'],
        instrument: Instrument.values.firstWhere(
          (e) => e.name == json['instrument'],
          orElse: () => Instrument.piano,
        ),
        notes: (json['notes'] as List?)
                ?.map((n) => NoteEvent.fromJson(n))
                .toList() ??
            [],
        volume: json['volume'] ?? 1.0,
        isMuted: json['isMuted'] ?? false,
        isSolo: json['isSolo'] ?? false,
        audioFilePath: json['audioFilePath'],
        duration: Duration(milliseconds: json['durationMs'] ?? 0),
      );
}

class NoteEvent {
  final int midiNote;
  final double frequency;
  final Duration startTime;
  final Duration duration;
  final double velocity;

  NoteEvent({
    required this.midiNote,
    required this.frequency,
    required this.startTime,
    required this.duration,
    this.velocity = 0.8,
  });

  Map<String, dynamic> toJson() => {
        'midiNote': midiNote,
        'frequency': frequency,
        'startTimeMs': startTime.inMilliseconds,
        'durationMs': duration.inMilliseconds,
        'velocity': velocity,
      };

  factory NoteEvent.fromJson(Map<String, dynamic> json) => NoteEvent(
        midiNote: json['midiNote'],
        frequency: json['frequency'],
        startTime: Duration(milliseconds: json['startTimeMs']),
        duration: Duration(milliseconds: json['durationMs']),
        velocity: json['velocity'] ?? 0.8,
      );
}
