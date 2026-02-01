import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/track_manager.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackManager>(
      builder: (context, trackManager, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                Row(
                  children: [
                    Text(
                      _formatDuration(trackManager.currentPosition),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: trackManager.totalDuration.inMilliseconds > 0
                            ? trackManager.currentPosition.inMilliseconds /
                                trackManager.totalDuration.inMilliseconds
                            : 0,
                        onChanged: (value) {
                          if (trackManager.totalDuration.inMilliseconds > 0) {
                            trackManager.seek(
                              Duration(
                                milliseconds: (value *
                                        trackManager
                                            .totalDuration.inMilliseconds)
                                    .round(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(trackManager.totalDuration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rewind
                    IconButton(
                      icon: const Icon(Icons.fast_rewind),
                      iconSize: 32,
                      onPressed: () {
                        final newPosition = trackManager.currentPosition -
                            const Duration(seconds: 10);
                        trackManager.seek(
                          newPosition < Duration.zero
                              ? Duration.zero
                              : newPosition,
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // Stop
                    IconButton(
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      onPressed: trackManager.stop,
                    ),

                    const SizedBox(width: 8),

                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          trackManager.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        iconSize: 48,
                        color: Colors.white,
                        onPressed: trackManager.isPlaying
                            ? trackManager.pause
                            : trackManager.play,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Fast Forward
                    IconButton(
                      icon: const Icon(Icons.fast_forward),
                      iconSize: 32,
                      onPressed: () {
                        final newPosition = trackManager.currentPosition +
                            const Duration(seconds: 10);
                        trackManager.seek(
                          newPosition > trackManager.totalDuration
                              ? trackManager.totalDuration
                              : newPosition,
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // Export
                    IconButton(
                      icon: const Icon(Icons.ios_share),
                      iconSize: 32,
                      onPressed: () => _showExportDialog(context),
                      tooltip: 'Export',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.audio_file),
              title: const Text('Export as WAV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting WAV...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Export as MP3'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting MP3...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
