import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_release_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_app_update_service.dart';

void main() {
  group('Pocket App Release & Update System Tests', () {
    test('1. Verify official store links for Android and iOS', () {
      expect(
        PocketReleaseService.defaultAndroidPlayStoreUrl,
        'https://play.google.com/store/apps/details?id=com.poketmates.app',
      );
      expect(
        PocketReleaseService.defaultIosAppStoreUrl,
        'https://apps.apple.com/in/app/poketmates/id6757978594',
      );
      expect(
        PocketAppUpdateService.defaultAndroidPlayStoreUrl,
        'https://play.google.com/store/apps/details?id=com.poketmates.app',
      );
      expect(
        PocketAppUpdateService.defaultIosStoreUrl,
        'https://apps.apple.com/in/app/poketmates/id6757978594',
      );
    });

    test('2. Version comparison: Older installed build triggers update', () {
      // User on 1.0.1 (build 500), Target production is 1.0.2 (build 501)
      final bool needsUpdate = PocketReleaseService.isInstalledBuildOutdated(
        currentVersion: '1.0.1',
        currentBuild: 500,
        targetVersion: '1.0.2',
        targetBuild: 501,
      );
      expect(needsUpdate, isTrue);
    });

    test('3. Version comparison: Updated build never triggers update again', () {
      // User updated to 1.0.2 (build 501), Target is 1.0.2 (build 501)
      final bool needsUpdate = PocketReleaseService.isInstalledBuildOutdated(
        currentVersion: '1.0.2',
        currentBuild: 501,
        targetVersion: '1.0.2',
        targetBuild: 501,
      );
      expect(needsUpdate, isFalse);
    });

    test('4. Version comparison: TestFlight / Newer internal builds are not prompted to downgrade', () {
      // Admin or tester on TestFlight build 1.0.10 (build 520), App Store approved 1.0.2 (build 501)
      final bool needsUpdate = PocketReleaseService.isInstalledBuildOutdated(
        currentVersion: '1.0.10',
        currentBuild: 520,
        targetVersion: '1.0.2',
        targetBuild: 501,
      );
      expect(needsUpdate, isFalse);
    });

    test('5. Semantic comparison without build numbers works accurately', () {
      // 1.0.1 vs 1.0.2
      expect(
        PocketReleaseService.isInstalledBuildOutdated(
          currentVersion: '1.0.1',
          currentBuild: 0,
          targetVersion: '1.0.2',
          targetBuild: 0,
        ),
        isTrue,
      );

      // 1.0.2 vs 1.0.2
      expect(
        PocketReleaseService.isInstalledBuildOutdated(
          currentVersion: '1.0.2',
          currentBuild: 0,
          targetVersion: '1.0.2',
          targetBuild: 0,
        ),
        isFalse,
      );

      // 1.1.0 vs 1.0.2
      expect(
        PocketReleaseService.isInstalledBuildOutdated(
          currentVersion: '1.1.0',
          currentBuild: 0,
          targetVersion: '1.0.2',
          targetBuild: 0,
        ),
        isFalse,
      );
    });

    test('6. AppReleaseRecord model serializes and parses properly', () {
      final record = AppReleaseRecord(
        id: 'rel_ios_1_0_2_501',
        platform: 'ios',
        version: '1.0.2',
        buildNumber: 501,
        releaseTitle: 'Major Citadel Update',
        releaseNotes: 'New battle features and smoother animations!',
        isMandatory: true,
        isActiveProduction: true,
        storeUrl: 'https://apps.apple.com/in/app/poketmates/id6757978594',
      );

      final json = record.toJson();
      expect(json['platform'], 'ios');
      expect(json['version'], '1.0.2');
      expect(json['build_number'], 501);
      expect(json['is_mandatory'], isTrue);
      expect(json['is_active_production'], isTrue);

      final fromJson = AppReleaseRecord.fromJson(json);
      expect(fromJson.platform, 'ios');
      expect(fromJson.version, '1.0.2');
      expect(fromJson.buildNumber, 501);
      expect(fromJson.isMandatory, isTrue);
      expect(fromJson.isActiveProduction, isTrue);
      expect(fromJson.storeUrl, 'https://apps.apple.com/in/app/poketmates/id6757978594');
    });
  });
}
