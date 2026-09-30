// lib/services/soundscape_service.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Representation of an ambient focus soundscape.
class SoundscapeTrack {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final String audioUrl;

  const SoundscapeTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.audioUrl,
  });
}

/// Catalog of curated ambient soundscapes for deep work and focus.
class SoundscapeCatalog {
  SoundscapeCatalog._();

  static const SoundscapeTrack gentleRain = SoundscapeTrack(
    id: 'gentle_rain',
    title: 'Gentle Rain',
    description: '1-Hour continuous rainfall for calm focus & deep work',
    iconEmoji: '🌧️',
    audioUrl: 'https://archive.org/download/relaxingsoundofrain/Relaxing%20Sound%20of%20Rain.mp3',
  );

  static const List<SoundscapeTrack> tracks = [
    gentleRain,
  ];

  static SoundscapeTrack? getById(String id) {
    if (id == 'gentle_rain') return gentleRain;
    return null;
  }
}

/// Core audio controller managing looping ambient playback.
class SoundscapeService {
  SoundscapeService._();
  static final SoundscapeService instance = SoundscapeService._();

  final AudioPlayer _player = AudioPlayer();
  SoundscapeTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.75;

  SoundscapeTrack? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get volume => _volume;

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
    } catch (e) {
      debugPrint('[SoundscapeService] Init warning: $e');
    }
  }

  Future<void> playTrack(SoundscapeTrack track) async {
    try {
      _isLoading = true;
      _currentTrack = track;
      
      // Stop and reset previous playback cleanly
      try {
        await _player.stop().timeout(const Duration(seconds: 2));
      } catch (_) {}

      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.loop);

      // Play direct MP3 with safety timeout
      await _player.play(UrlSource(track.audioUrl)).timeout(const Duration(seconds: 8));

      _isPlaying = true;
      _isLoading = false;
      debugPrint('[SoundscapeService] Successfully playing soundscape: ${track.title}');
    } catch (e) {
      debugPrint('[SoundscapeService] Error playing soundscape ${track.title}: $e');
      _isPlaying = false;
      _isLoading = false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause().timeout(const Duration(seconds: 2));
      _isPlaying = false;
    } catch (e) {
      debugPrint('[SoundscapeService] Pause error: $e');
    }
  }

  Future<void> resume() async {
    if (_currentTrack == null) return;
    try {
      await _player.resume().timeout(const Duration(seconds: 3));
      _isPlaying = true;
    } catch (e) {
      debugPrint('[SoundscapeService] Resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop().timeout(const Duration(seconds: 2));
      _isPlaying = false;
    } catch (e) {
      debugPrint('[SoundscapeService] Stop error: $e');
    }
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
    } catch (e) {
      debugPrint('[SoundscapeService] Volume error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
