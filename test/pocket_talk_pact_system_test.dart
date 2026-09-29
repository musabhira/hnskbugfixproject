import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('PocketTalk Pact & Protection Guard Tests', () {
    test('Requesting a pact creates an unaccepted pact with hasBothSpoken = false', () async {
      final pact = await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
        autoAccept: false,
      );

      expect(pact, isNotNull);
      expect(pact!.isAccepted, isFalse);
      expect(pact.hasBothSpoken, isFalse);
      expect(pact.isForfeited, isFalse);
    });

    test('Accepting a pact activates it', () async {
      await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
        autoAccept: false,
      );

      final accepted = await PocketTrophyService.acceptPact(
        myId: 'user_bob',
        otherUserId: 'user_alice',
      );

      expect(accepted, isNotNull);
      expect(accepted!.isAccepted, isTrue);
      expect(accepted.hasBothSpoken, isFalse);
    });

    test('Protection Guard: If recipient never replied/participated, no penalty on checkAndEvaluatePact', () async {
      // User Alice requested and User Bob accepted, but Bob never spoke (hasBothSpoken = false)
      await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
        autoAccept: false,
      );
      await PocketTrophyService.acceptPact(
        myId: 'user_bob',
        otherUserId: 'user_alice',
      );

      final eval = await PocketTrophyService.checkAndEvaluatePact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
      );

      expect(eval, isNotNull);
      expect(eval!.didBreach, isFalse);
      expect(eval.deductedTrophy, isFalse);
    });

    test('Engagement marking unlocks 2-way accountability', () async {
      await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
        autoAccept: true,
      );

      // Alice & Bob send messages
      await PocketTrophyService.markUserEngagement(
        myId: 'user_alice',
        otherUserId: 'user_bob',
      );

      final pact = await PocketTrophyService.getPact('user_alice', 'user_bob');
      expect(pact, isNotNull);
      expect(pact!.hasBothSpoken, isTrue);
    });

    test('getAllActiveOrPendingPactUserIds correctly returns peers for filter ribbon', () async {
      await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_bob',
        autoAccept: false,
      );
      await PocketTrophyService.requestPact(
        myId: 'user_alice',
        otherUserId: 'user_clara',
        autoAccept: true,
      );

      final alicePeers = await PocketTrophyService.getAllActiveOrPendingPactUserIds('user_alice');
      expect(alicePeers.contains('user_bob'), isTrue);
      expect(alicePeers.contains('user_clara'), isTrue);
      expect(alicePeers.contains('user_alice'), isFalse);
    });
  });
}
