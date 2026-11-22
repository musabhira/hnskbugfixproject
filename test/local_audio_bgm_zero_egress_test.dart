import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Zero-Egress Local Audio BGM Engine Tests', () {
    test('All homeTracks point to local assets with no Supabase URL', () {
      expect(PocketGameAudioService.homeTracks.isNotEmpty, isTrue);

      for (final track in PocketGameAudioService.homeTracks) {
        expect(track.url.startsWith('http'), isFalse,
            reason: 'Track ${track.title} should not be a remote URL');
        expect(track.url.startsWith('audio/bgm/'), isTrue,
            reason: 'Track ${track.title} should point to audio/bgm/');

        final file = File('assets/${track.url}');
        expect(file.existsSync(), isTrue,
            reason: 'Asset file assets/${track.url} must exist on disk');
      }
    });

    test('All attackTracks point to local assets with no Supabase URL', () {
      expect(PocketGameAudioService.attackTracks.isNotEmpty, isTrue);

      for (final track in PocketGameAudioService.attackTracks) {
        expect(track.url.startsWith('http'), isFalse,
            reason: 'Track ${track.title} should not be a remote URL');
        expect(track.url.startsWith('audio/bgm/'), isTrue,
            reason: 'Track ${track.title} should point to audio/bgm/');

        final file = File('assets/${track.url}');
        expect(file.existsSync(), isTrue,
            reason: 'Asset file assets/${track.url} must exist on disk');
      }
    });

    test('Attack track selection safely resolves across archetypes and levels', () {
      final t1 = PocketGameAudioService.getTrackForAttack(targetId: 'robot_1', targetDay: 1);
      final t2 = PocketGameAudioService.getTrackForAttack(targetId: 'robot_1', targetDay: 45);
      final tPres = PocketGameAudioService.getTrackForAttack(targetId: 'pocket_president');

      expect(t1.url.startsWith('audio/bgm/'), isTrue);
      expect(t2.url.startsWith('audio/bgm/'), isTrue);
      expect(tPres.url.startsWith('audio/bgm/'), isTrue);
    });

    test('Home track selection safely resolves for various houses', () {
      final h1 = PocketGameAudioService.getTrackForHouse('house_abc');
      final h2 = PocketGameAudioService.getTrackForHouse('house_xyz');

      expect(h1.url.startsWith('audio/bgm/'), isTrue);
      expect(h2.url.startsWith('audio/bgm/'), isTrue);
    });
  });
}
