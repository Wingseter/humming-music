import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/track_manager.dart';
import '../models/instrument.dart';
import 'recording_screen.dart';
import '../widgets/track_list_item.dart';
import '../widgets/playback_controls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Humming Music'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveProject(context),
            tooltip: 'Save Project',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => _loadProject(context),
            tooltip: 'Load Project',
          ),
        ],
      ),
      body: Column(
        children: [
          // Track List
          Expanded(
            child: Consumer<TrackManager>(
              builder: (context, trackManager, child) {
                if (trackManager.tracks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tracks yet',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a new track',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  itemCount: trackManager.tracks.length,
                  onReorder: (oldIndex, newIndex) {
                    // Implement reorder logic
                  },
                  itemBuilder: (context, index) {
                    final track = trackManager.tracks[index];
                    return TrackListItem(
                      key: ValueKey(track.id),
                      track: track,
                      isSelected: index == trackManager.currentTrackIndex,
                      onTap: () => trackManager.selectTrack(index),
                      onRecord: () => _navigateToRecording(context, track.id),
                    );
                  },
                );
              },
            ),
          ),

          // Playback Controls
          const PlaybackControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTrackDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Track'),
      ),
    );
  }

  void _showAddTrackDialog(BuildContext context) {
    final trackManager = context.read<TrackManager>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Instrument',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Instrument.values.map((instrument) {
                  return InkWell(
                    onTap: () {
                      trackManager.addTrack(instrument: instrument);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: instrument.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: instrument.color.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            instrument.icon,
                            color: instrument.color,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            instrument.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: instrument.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _navigateToRecording(BuildContext context, String trackId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingScreen(trackId: trackId),
      ),
    );
  }

  void _saveProject(BuildContext context) async {
    final trackManager = context.read<TrackManager>();
    
    final controller = TextEditingController(text: 'My Project');
    
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final path = await trackManager.saveProject(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      }
    }
  }

  void _loadProject(BuildContext context) {
    // Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Load project - coming soon')),
    );
  }
}
