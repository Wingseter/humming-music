import 'package:flutter/material.dart';

class PitchVisualizer extends StatelessWidget {
  final double currentPitch;
  final String currentNote;
  final int midiNote;

  const PitchVisualizer({
    super.key,
    required this.currentPitch,
    required this.currentNote,
    required this.midiNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Note Display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              currentNote.isNotEmpty ? currentNote : '--',
              key: ValueKey(currentNote),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: currentNote.isNotEmpty
                    ? _getNoteColor(midiNote)
                    : Colors.grey[700],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Frequency Display
          Text(
            currentPitch > 0
                ? '${currentPitch.toStringAsFixed(1)} Hz'
                : '-- Hz',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),

          const SizedBox(height: 32),

          // Piano Roll Visualization
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _PianoRollPainter(
                currentMidiNote: midiNote,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pitch Indicator Bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Current pitch indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  left: _getPitchPosition(currentPitch),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Frequency Range Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '80 Hz',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                '440 Hz',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                '1000 Hz',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getNoteColor(int midi) {
    final noteIndex = midi % 12;
    const colors = [
      Colors.red,      // C
      Colors.deepOrange, // C#
      Colors.orange,   // D
      Colors.amber,    // D#
      Colors.yellow,   // E
      Colors.lime,     // F
      Colors.green,    // F#
      Colors.teal,     // G
      Colors.cyan,     // G#
      Colors.blue,     // A
      Colors.indigo,   // A#
      Colors.purple,   // B
    ];
    return colors[noteIndex];
  }

  double _getPitchPosition(double pitch) {
    if (pitch <= 0) return 0;
    // Map 80-1000 Hz to 0-width
    final normalized = (pitch - 80) / (1000 - 80);
    return normalized.clamp(0, 1) * 300; // Assuming 300 width
  }
}

class _PianoRollPainter extends CustomPainter {
  final int currentMidiNote;

  _PianoRollPainter({required this.currentMidiNote});

  @override
  void paint(Canvas canvas, Size size) {
    final whiteKeyWidth = size.width / 14;
    final blackKeyWidth = whiteKeyWidth * 0.6;
    
    // Draw white keys (C3 to C5 - 2 octaves)
    int whiteKeyIndex = 0;
    for (int i = 48; i <= 72; i++) {
      if (!_isBlackKey(i)) {
        final isCurrentNote = i == currentMidiNote;
        final rect = Rect.fromLTWH(
          whiteKeyIndex * whiteKeyWidth,
          0,
          whiteKeyWidth - 2,
          size.height,
        );
        
        final paint = Paint()
          ..color = isCurrentNote ? Colors.deepPurple : Colors.white
          ..style = PaintingStyle.fill;
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
        
        // Border
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = Colors.grey[400]!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        
        whiteKeyIndex++;
      }
    }

    // Draw black keys
    whiteKeyIndex = 0;
    for (int i = 48; i <= 72; i++) {
      if (!_isBlackKey(i)) {
        // Check if next note is black
        if (i + 1 <= 72 && _isBlackKey(i + 1)) {
          final isCurrentNote = (i + 1) == currentMidiNote;
          final rect = Rect.fromLTWH(
            (whiteKeyIndex + 1) * whiteKeyWidth - blackKeyWidth / 2,
            0,
            blackKeyWidth,
            size.height * 0.6,
          );
          
          final paint = Paint()
            ..color = isCurrentNote ? Colors.deepPurple : Colors.black
            ..style = PaintingStyle.fill;
          
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
        }
        whiteKeyIndex++;
      }
    }
  }

  bool _isBlackKey(int midi) {
    final note = midi % 12;
    return [1, 3, 6, 8, 10].contains(note);
  }

  @override
  bool shouldRepaint(covariant _PianoRollPainter oldDelegate) {
    return oldDelegate.currentMidiNote != currentMidiNote;
  }
}
