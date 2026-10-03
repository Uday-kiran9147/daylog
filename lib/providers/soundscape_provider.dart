// lib/providers/soundscape_provider.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import '../services/soundscape_service.dart';

class SoundscapeState {
  final SoundscapeTrack? currentTrack;
  final bool isPlaying;
  final bool isBuffering;
  final double volume;
  final DateTime? passExpiresAt;
  final DateTime? previewEndsAt;
  final bool isAdLoading;

  const SoundscapeState({
    this.currentTrack,
    this.isPlaying = false,
    this.isBuffering = false,
    this.volume = 0.75,
    this.passExpiresAt,
    this.previewEndsAt,
    this.isAdLoading = false,
  });

  bool get isPassActive {
    if (passExpiresAt == null) return false;
    return DateTime.now().isBefore(passExpiresAt!);
  }

  bool get isPreviewActive {
    if (previewEndsAt == null) return false;
    return DateTime.now().isBefore(previewEndsAt!);
  }

  bool get hasAudioAccess => isPassActive || isPreviewActive;

  int get remainingPassMinutes {
    if (passExpiresAt == null) return 0;
    final diff = passExpiresAt!.difference(DateTime.now()).inMinutes;
    return diff > 0 ? diff : 0;
  }

  int get remainingPreviewSeconds {
    if (previewEndsAt == null) return 0;
    final diff = previewEndsAt!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  SoundscapeState copyWith({
    SoundscapeTrack? Function()? currentTrack,
    bool? isPlaying,
    bool? isBuffering,
    double? volume,
    DateTime? Function()? passExpiresAt,
    DateTime? Function()? previewEndsAt,
    bool? isAdLoading,
  }) {
    return SoundscapeState(
      currentTrack: currentTrack != null ? currentTrack() : this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      passExpiresAt: passExpiresAt != null ? passExpiresAt() : this.passExpiresAt,
      previewEndsAt: previewEndsAt != null ? previewEndsAt() : this.previewEndsAt,
      isAdLoading: isAdLoading ?? this.isAdLoading,
    );
  }
}

class SoundscapeNotifier extends StateNotifier<SoundscapeState> {
  SoundscapeNotifier() : super(const SoundscapeState()) {
    _init();
  }

  Timer? _tickerTimer;
  StreamSubscription<PlayerState>? _playerSub;

  void _init() {
    SoundscapeService.instance.init();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _playerSub = SoundscapeService.instance.onPlayerStateChanged.listen((playerState) {
      if (!mounted) return;
      final isPlaying = playerState == PlayerState.playing;
      if (state.isPlaying != isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _playerSub?.cancel();
    super.dispose();
  }

  void _tick() {
    if (state.isPlaying && !state.hasAudioAccess) {
      // Access expired, pause sound
      SoundscapeService.instance.pause();
      state = state.copyWith(isPlaying: false);
    }
  }

  /// Selects, tests, and plays any soundscape immediately.
  /// Allows users to audition and test all sounds freely before finalizing.
  Future<void> selectTrack(SoundscapeTrack track) async {
    DateTime? newPreviewEndsAt = state.previewEndsAt;
    
    // If user doesn't have an active 60-min pass, ensure they have at least 3 minutes
    // of preview time on each track they test so they can audition every track!
    if (!state.isPassActive) {
      final now = DateTime.now();
      if (newPreviewEndsAt == null || newPreviewEndsAt.isBefore(now.add(const Duration(minutes: 2)))) {
        newPreviewEndsAt = now.add(const Duration(minutes: 3));
      }
    }

    state = state.copyWith(
      currentTrack: () => track,
      previewEndsAt: () => newPreviewEndsAt,
      isPlaying: true,
      isBuffering: true,
    );

    await SoundscapeService.instance.playTrack(track);

    if (mounted) {
      state = state.copyWith(
        isBuffering: false,
        isPlaying: SoundscapeService.instance.isPlaying,
      );
    }
  }

  /// Toggles playback on/off.
  Future<void> togglePlayPause() async {
    if (state.currentTrack == null) {
      if (SoundscapeCatalog.tracks.isNotEmpty) {
        await selectTrack(SoundscapeCatalog.tracks.first);
      }
      return;
    }

    if (state.isPlaying) {
      await SoundscapeService.instance.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      if (!state.hasAudioAccess) {
        // Grant a 3-minute audition preview if expired
        final newPreview = DateTime.now().add(const Duration(minutes: 3));
        state = state.copyWith(previewEndsAt: () => newPreview);
      }
      await SoundscapeService.instance.resume();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Sets audio volume.
  Future<void> setVolume(double vol) async {
    state = state.copyWith(volume: vol);
    await SoundscapeService.instance.setVolume(vol);
  }

  /// Stops audio playback.
  Future<void> stop() async {
    await SoundscapeService.instance.stop();
    state = state.copyWith(isPlaying: false);
  }

  /// Unlocks or extends the 60-Minute Focus Audio Pass by watching a rewarded sponsor ad.
  void unlock60MinPass({
    required VoidCallback onRewardGranted,
    required void Function(String message) onError,
  }) {
    state = state.copyWith(isAdLoading: true);

    AdService.instance.showRewardedAd(
      placement: 'soundscape_60m_pass',
      onUserEarnedReward: (reward) {
        final currentExpiry = state.isPassActive
            ? state.passExpiresAt!
            : DateTime.now();
        final newExpiry = currentExpiry.add(const Duration(minutes: 60));

        state = state.copyWith(
          passExpiresAt: () => newExpiry,
          isAdLoading: false,
        );

        // Resume playing if a track is selected
        if (state.currentTrack != null && !state.isPlaying) {
          SoundscapeService.instance.resume();
          state = state.copyWith(isPlaying: true);
        }

        onRewardGranted();
      },
      onDismissed: () {
        state = state.copyWith(isAdLoading: false);
      },
      onAdNotReady: () {
        state = state.copyWith(isAdLoading: false);
        // Fallback: In debug or offline scenarios, grant grace 30 min pass so user isn't stuck
        final fallbackExpiry = DateTime.now().add(const Duration(minutes: 30));
        state = state.copyWith(passExpiresAt: () => fallbackExpiry);
        onError('Sponsor pass granted in offline grace mode (+30m)!');
      },
    );
  }
}

final soundscapeProvider =
    StateNotifierProvider<SoundscapeNotifier, SoundscapeState>((ref) {
  return SoundscapeNotifier();
});
