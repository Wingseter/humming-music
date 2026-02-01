import 'package:flutter/material.dart';

enum Instrument {
  piano(
    displayName: 'Piano',
    icon: Icons.piano,
    color: Colors.white,
    midiProgram: 0,
  ),
  guitar(
    displayName: 'Guitar',
    icon: Icons.music_note,
    color: Colors.brown,
    midiProgram: 25,
  ),
  violin(
    displayName: 'Violin',
    icon: Icons.music_note,
    color: Colors.amber,
    midiProgram: 40,
  ),
  trumpet(
    displayName: 'Trumpet',
    icon: Icons.music_note,
    color: Colors.yellow,
    midiProgram: 56,
  ),
  saxophone(
    displayName: 'Saxophone',
    icon: Icons.music_note,
    color: Colors.orange,
    midiProgram: 65,
  ),
  flute(
    displayName: 'Flute',
    icon: Icons.music_note,
    color: Colors.grey,
    midiProgram: 73,
  ),
  synth(
    displayName: 'Synth',
    icon: Icons.waves,
    color: Colors.purple,
    midiProgram: 81,
  ),
  bass(
    displayName: 'Bass',
    icon: Icons.music_note,
    color: Colors.indigo,
    midiProgram: 33,
  );

  final String displayName;
  final IconData icon;
  final Color color;
  final int midiProgram;

  const Instrument({
    required this.displayName,
    required this.icon,
    required this.color,
    required this.midiProgram,
  });
}
