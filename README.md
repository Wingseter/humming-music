# 🎵 Humming Music

사용자의 허밍/음성을 분석하여 원하는 악기 소리로 변환하고, 
여러 트랙을 합주할 수 있는 스마트폰 앱

## 🎯 핵심 기능

1. **음정/음율 분석** - 실시간 pitch detection
2. **악기 변환** - 허밍 → 피아노, 기타, 바이올린 등
3. **멀티 트랙** - Logic Pro처럼 여러 트랙 녹음/합주
4. **내보내기** - 완성된 곡을 오디오 파일로 저장

## 🔬 기술 스택 (제안)

### 모바일 프레임워크
| 옵션 | 장점 | 단점 |
|------|------|------|
| **Flutter** | 크로스플랫폼, 빠른 개발 | 오디오 처리 네이티브 필요 |
| **React Native** | 커뮤니티 큼, JS 생태계 | 성능 이슈 가능 |
| **Native (Swift/Kotlin)** | 최고 성능 | 개발 비용 2배 |

### 음정 감지 라이브러리
- **Flutter**: `flutter_detect_pitch`
- **React Native**: `react-native-pitchy`, `react-native-live-pitch-detection`
- **Native iOS**: AVAudioEngine + FFT
- **Native Android**: TarsosDSP

### 악기 변환 기술
| 기술 | 설명 |
|------|------|
| **MIDI + SoundFont** | 음정 → MIDI 노트 → 악기 샘플 재생 |
| **AI Voice-to-Instrument** | Magenta, DDSP (Google), Tone Transfer |
| **Neural Audio Synthesis** | 딥러닝 기반 음색 변환 |

### 오디오 처리
- **AudioKit** (iOS) - 강력한 오디오 프레임워크
- **Oboe** (Android) - 저지연 오디오
- **Superpowered** - 크로스플랫폼 오디오 SDK

## 📱 유사 앱 분석

| 앱 | 특징 | 참고 |
|----|------|------|
| **HumBeatz** | 허밍→악기, 비트메이킹 | iOS/Android |
| **HumOn** | 멜로디 인식, 악보 변환 | 한국 앱 |
| **Humming to Music Maker** | AI 기반 음악 생성 | Android |
| **Google Tone Transfer** | 웹앱, 4개 악기 | 무료 |

## 🏗️ 프로젝트 구조 (Flutter 기준)

```
humming_music/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── recording_screen.dart
│   │   ├── tracks_screen.dart
│   │   └── export_screen.dart
│   ├── services/
│   │   ├── pitch_detector.dart      # 음정 감지
│   │   ├── instrument_converter.dart # 악기 변환
│   │   ├── audio_recorder.dart       # 녹음
│   │   └── track_mixer.dart          # 트랙 믹싱
│   ├── models/
│   │   ├── track.dart
│   │   ├── note.dart
│   │   └── instrument.dart
│   └── widgets/
│       ├── waveform_view.dart
│       ├── track_timeline.dart
│       └── instrument_picker.dart
├── assets/
│   └── soundfonts/              # 악기 샘플
├── android/
├── ios/
└── pubspec.yaml
```

## 🎹 지원 악기 (MVP)

- 🎹 피아노
- 🎸 어쿠스틱 기타
- 🎻 바이올린
- 🎺 트럼펫
- 🎷 색소폰
- 🪈 플룻

## 📋 개발 단계

### Phase 1: 기초 (2-3주)
- [ ] 프로젝트 설정 (Flutter)
- [ ] 마이크 권한 및 녹음 기능
- [ ] 실시간 pitch detection
- [ ] 기본 UI

### Phase 2: 변환 (2-3주)
- [ ] MIDI 노트 변환
- [ ] SoundFont 통합
- [ ] 악기 선택 UI
- [ ] 실시간 악기 소리 재생

### Phase 3: 멀티트랙 (2-3주)
- [ ] 트랙 관리 (추가/삭제/뮤트)
- [ ] 타임라인 UI
- [ ] 트랙 동기화 및 믹싱
- [ ] 재생/정지/탐색

### Phase 4: 완성 (1-2주)
- [ ] 오디오 내보내기 (WAV/MP3)
- [ ] 프로젝트 저장/불러오기
- [ ] UI 폴리싱
- [ ] 테스트 및 버그 수정

## 🔧 핵심 알고리즘

### 1. Pitch Detection
```dart
// YIN 알고리즘 또는 CREPE (딥러닝)
double detectPitch(List<double> audioBuffer, int sampleRate) {
  // FFT 기반 주파수 분석
  // 또는 자기상관(autocorrelation) 기반
}
```

### 2. Frequency → MIDI Note
```dart
int frequencyToMidi(double freq) {
  // A4 = 440Hz = MIDI 69
  return (12 * log2(freq / 440) + 69).round();
}
```

### 3. MIDI → Instrument Sound
```dart
void playInstrument(int midiNote, Instrument instrument) {
  // SoundFont 샘플 재생
  // 또는 신디사이저 생성
}
```

## 📚 참고 자료

- [Google Magenta DDSP](https://magenta.tensorflow.org/ddsp)
- [Tone Transfer](https://sites.research.google/tonetransfer)
- [AudioKit Documentation](https://audiokit.io/)
- [flutter_detect_pitch](https://pub.dev/packages/flutter_detect_pitch)
- [TarsosDSP (Java)](https://github.com/JorenSix/TarsosDSP)

## 💡 차별화 포인트

1. **실시간 변환** - 녹음하면서 바로 악기 소리로 들림
2. **쉬운 UI** - 비전문가도 바로 사용 가능
3. **합주 기능** - 혼자서 밴드 연주 가능
4. **공유** - SNS 공유 기능

---

*Created: 2026-02-01*
*Author: MolgaAssist 🦎*
