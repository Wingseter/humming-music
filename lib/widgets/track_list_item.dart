import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/track_manager.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRecord;

  const TrackListItem({
    super.key,
    required this.track,
    required this.isSelected,
    required this.onTap,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final trackManager = context.read<TrackManager>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected
          ? track.instrument.color.withOpacity(0.2)
          : Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Instrument Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: track.instrument.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  track.instrument.icon,
                  color: track.instrument.color,
                ),
              ),
              const SizedBox(width: 12),

              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          track.instrument.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (track.duration > Duration.zero) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(track.duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        if (track.notes.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${track.notes.length} notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Volume Slider
              SizedBox(
                width: 80,
                child: Slider(
                  value: track.volume,
                  onChanged: (value) {
                    trackManager.setTrackVolume(track.id, value);
                  },
                  activeColor: track.instrument.color,
                ),
              ),

              // Mute Button
              IconButton(
                icon: Icon(
                  track.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: track.isMuted ? Colors.red : Colors.grey,
                ),
                onPressed: () => trackManager.toggleMute(track.id),
                tooltip: 'Mute',
              ),

              // Solo Button
              IconButton(
                icon: Icon(
                  Icons.headphones,
                  color: track.isSolo ? Colors.amber : Colors.grey,
                ),
                onPressed: () => trackManager.toggleSolo(track.id),
                tooltip: 'Solo',
              ),

              // Record Button
              IconButton(
                icon: const Icon(Icons.fiber_manual_record),
                color: Colors.red,
                onPressed: onRecord,
                tooltip: 'Record',
              ),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey,
                onPressed: () => _confirmDelete(context, trackManager),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, TrackManager trackManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Track?'),
        content: Text('Are you sure you want to delete "${track.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              trackManager.removeTrack(track.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
