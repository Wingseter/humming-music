import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/track.dart';

class WaveformView extends StatefulWidget {
  final bool isRecording;
  final List<NoteEvent> notes;

  const WaveformView({
    super.key,
    required this.isRecording,
    required this.notes,
  });

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.graphic_eq,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                widget.isRecording
                    ? 'Recording... (${widget.notes.length} notes)'
                    : 'Recorded ${widget.notes.length} notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _WaveformPainter(
                    notes: widget.notes,
                    isRecording: widget.isRecording,
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<NoteEvent> notes;
  final bool isRecording;
  final double animationValue;

  _WaveformPainter({
    required this.notes,
    required this.isRecording,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty && !isRecording) {
      // Draw placeholder
      final paint = Paint()
        ..color = Colors.grey[700]!
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      canvas.drawPath(path, paint);
      return;
    }

    // Draw note bars
    final barPaint = Paint()
      ..style = PaintingStyle.fill;

    final totalDuration = notes.isNotEmpty
        ? notes.last.startTime.inMilliseconds +
            notes.last.duration.inMilliseconds
        : 10000;

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      
      // Calculate position
      final x = (note.startTime.inMilliseconds / totalDuration) * size.width;
      final width = math.max(
        2.0,
        (note.duration.inMilliseconds / totalDuration) * size.width,
      );

      // Calculate height based on MIDI note (higher note = higher bar)
      final normalizedPitch = (note.midiNote - 48) / 36; // C3 to C6
      final barHeight = normalizedPitch.clamp(0.0, 1.0) * size.height * 0.8;
      final y = (size.height - barHeight) / 2;

      // Color based on note
      final hue = (note.midiNote % 12) * 30.0;
      barPaint.color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width, barHeight),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }

    // Draw recording indicator
    if (isRecording) {
      final indicatorPaint = Paint()
        ..color = Colors.red.withOpacity(0.5 + animationValue * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width - 10, 10),
        5,
        indicatorPaint,
      );
    }

    // Draw center line
    final linePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.notes.length != notes.length ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.animationValue != animationValue;
  }
}
