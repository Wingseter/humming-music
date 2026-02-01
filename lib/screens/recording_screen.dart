import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/track_manager.dart';
import '../widgets/pitch_visualizer.dart';
import '../widgets/waveform_view.dart';

class RecordingScreen extends StatefulWidget {
  final String trackId;

  const RecordingScreen({
    super.key,
    required this.trackId,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    final audioService = context.read<AudioService>();
    try {
      await audioService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackManager = context.read<TrackManager>();
    final track = trackManager.tracks.firstWhere(
      (t) => t.id == widget.trackId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Recording: ${track.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveRecording,
            tooltip: 'Save Recording',
          ),
        ],
      ),
      body: Consumer<AudioService>(
        builder: (context, audioService, child) {
          return Column(
            children: [
              // Instrument Info
              Container(
                padding: const EdgeInsets.all(16),
                color: track.instrument.color.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      track.instrument.icon,
                      color: track.instrument.color,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.instrument.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hum your melody and it will be converted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pitch Visualizer
              Expanded(
                flex: 2,
                child: PitchVisualizer(
                  currentPitch: audioService.currentPitch,
                  currentNote: audioService.currentNoteName,
                  midiNote: audioService.currentMidiNote,
                ),
              ),

              // Waveform
              Expanded(
                flex: 1,
                child: WaveformView(
                  isRecording: audioService.isRecording,
                  notes: audioService.recordedNotes,
                ),
              ),

              // Recording Controls
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Status
                    Text(
                      audioService.isRecording
                          ? '🔴 Recording...'
                          : 'Ready to record',
                      style: TextStyle(
                        fontSize: 16,
                        color: audioService.isRecording
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Record Button
                    GestureDetector(
                      onTap: () => _toggleRecording(audioService),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: audioService.isRecording
                              ? Colors.red
                              : Colors.deepPurple,
                          boxShadow: [
                            BoxShadow(
                              color: (audioService.isRecording
                                      ? Colors.red
                                      : Colors.deepPurple)
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: audioService.isRecording ? 5 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          audioService.isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tips
                    Text(
                      'Tip: Hum clearly and steadily for best results',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleRecording(AudioService audioService) async {
    if (audioService.isRecording) {
      final path = await audioService.stopRecording();
      setState(() {
        _recordingPath = path;
      });
    } else {
      final path = await audioService.startRecording();
      setState(() {
        _recordingPath = path;
      });
    }
  }

  void _saveRecording() {
    final audioService = context.read<AudioService>();
    final trackManager = context.read<TrackManager>();

    if (audioService.recordedNotes.isNotEmpty) {
      trackManager.updateTrack(
        widget.trackId,
        notes: audioService.recordedNotes,
        audioFilePath: _recordingPath,
        duration: audioService.recordedNotes.isNotEmpty
            ? audioService.recordedNotes.last.startTime +
                audioService.recordedNotes.last.duration
            : Duration.zero,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording saved!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording to save')),
      );
    }
  }
}
