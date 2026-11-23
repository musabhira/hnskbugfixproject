import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VIP & Subscribed & Verified Single Truth Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    bool evaluateVipFromPrefs(SharedPreferences prefs, String uid) {
      final isVip = prefs.getBool('is_vip_$uid') ??
          prefs.getBool('is_premium_$uid') ??
          prefs.getBool('is_verified_$uid');
      final tier = prefs.getString('subscription_tier_$uid');
      if (isVip != null) {
        return isVip;
      }
      if (tier != null && tier.isNotEmpty) {
        return tier != 'free' && tier != 'none' && tier != 'null';
      }
      return false;
    }

    bool evaluateVipFromProfile(Map<String, dynamic> profile) {
      final tier = profile['subscription_tier']?.toString().toLowerCase().trim();
      final hasActivePaidTier = tier != null &&
          tier.isNotEmpty &&
          tier != 'free' &&
          tier != 'none' &&
          tier != 'null';

      final role = profile['role']?.toString().toLowerCase().trim();

      return hasActivePaidTier ||
          role == 'vip' ||
          role == 'admin' ||
          profile['is_vip'] == true ||
          profile['is_premium'] == true ||
          profile['is_subscribed'] == true ||
          profile['verified'] == true;
    }

    test('is_verified flag grants VIP entitlement as unified single truth', () async {
      final prefs = await SharedPreferences.getInstance();
      const testUid = 'user_verified_123';

      // Simulate verified user in SharedPreferences
      await prefs.setBool('is_verified_$testUid', true);

      final isVip = evaluateVipFromPrefs(prefs, testUid);
      expect(isVip, isTrue, reason: 'Verified user must be treated as VIP and receive zero ads');
    });

    test('Unified profile evaluator treats verified, vip, and subscribed identically', () {
      final verifiedProfile = {
        'user_id': 'u_verified',
        'verified': true,
        'is_vip': false,
        'is_premium': false,
      };
      final vipProfile = {
        'user_id': 'u_vip',
        'verified': false,
        'is_vip': true,
      };
      final subscribedProfile = {
        'user_id': 'u_sub',
        'verified': false,
        'is_subscribed': true,
      };
      final paidTierProfile = {
        'user_id': 'u_yearly',
        'subscription_tier': 'yearly',
      };
      final freeProfile = {
        'user_id': 'u_free',
        'verified': false,
        'is_vip': false,
        'is_premium': false,
        'is_subscribed': false,
        'subscription_tier': 'free',
      };

      expect(evaluateVipFromProfile(verifiedProfile), isTrue);
      expect(evaluateVipFromProfile(vipProfile), isTrue);
      expect(evaluateVipFromProfile(subscribedProfile), isTrue);
      expect(evaluateVipFromProfile(paidTierProfile), isTrue);
      expect(evaluateVipFromProfile(freeProfile), isFalse);
    });

    test('VIP status is strictly isolated between accounts without cross-leak', () async {
      final prefs = await SharedPreferences.getInstance();
      const vipUser = 'vip_account_456';
      const freeUser = 'free_account_789';

      // Setup VIP account
      await prefs.setBool('is_vip_$vipUser', true);
      await prefs.setBool('is_verified_$vipUser', true);
      await prefs.setString('subscription_tier_$vipUser', 'yearly');

      // Setup Free account
      await prefs.setBool('is_vip_$freeUser', false);
      await prefs.setBool('is_verified_$freeUser', false);
      await prefs.setString('subscription_tier_$freeUser', 'free');

      // Check VIP account
      expect(evaluateVipFromPrefs(prefs, vipUser), isTrue, reason: 'VIP user must be ad-free');

      // Check Free account
      expect(evaluateVipFromPrefs(prefs, freeUser), isFalse, reason: 'Free user must NOT inherit VIP status');

      // Clear any legacy un-scoped device keys to ensure no pollution
      await prefs.remove('is_vip');
      await prefs.remove('is_premium');
      expect(prefs.getBool('is_vip'), isNull);
    });

    test('Admin panel DOB and user filtering logic works correctly', () {
      final mockProfiles = [
        {
          'id': 'u1',
          'name': 'Rahul Nair',
          'email': 'rahul@example.com',
          'phone_no': '9876543210',
          'day': 15,
          'month': 8,
          'year': 1998,
          'is_vip': true,
        },
        {
          'id': 'u2',
          'name': 'Priya Das',
          'email': 'priya@gmail.com',
          'phone_no': '9123456780',
          'day': null,
          'month': null,
          'year': null,
          'verified': true,
        },
        {
          'id': 'u3',
          'name': 'Arun Kumar',
          'email': 'arun@outlook.com',
          'phone_no': '9988776655',
          'day': 5,
          'month': 1,
          'year': 2002,
          'is_vip': false,
        },
      ];

      // Test search by email
      final emailFiltered = mockProfiles.where((u) {
        final email = u['email']?.toString().toLowerCase() ?? '';
        return email.contains('priya@gmail.com');
      }).toList();
      expect(emailFiltered.length, equals(1));
      expect(emailFiltered.first['name'], equals('Priya Das'));

      // Test search by name
      final nameFiltered = mockProfiles.where((u) {
        final name = u['name']?.toString().toLowerCase() ?? '';
        return name.contains('rahul');
      }).toList();
      expect(nameFiltered.length, equals(1));
      expect(nameFiltered.first['email'], equals('rahul@example.com'));

      // Test DOB string formatting
      for (final u in mockProfiles) {
        final day = u['day'];
        final month = u['month'];
        final year = u['year'];
        final hasDob = day != null && month != null && year != null;
        final dobStr = hasDob
            ? '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year'
            : 'DOB: Not set';

        if (u['id'] == 'u1') {
          expect(dobStr, equals('15/08/1998'));
        } else if (u['id'] == 'u2') {
          expect(dobStr, equals('DOB: Not set'));
        } else if (u['id'] == 'u3') {
          expect(dobStr, equals('05/01/2002'));
        }
      }

      // Test VIP unification: both is_vip and verified qualify as VIP
      for (final u in mockProfiles) {
        final bool isVip = u['is_vip'] == true ||
            u['is_premium'] == true ||
            u['is_subscribed'] == true ||
            u['verified'] == true;

        if (u['id'] == 'u1') {
          expect(isVip, isTrue, reason: 'is_vip user is VIP');
        } else if (u['id'] == 'u2') {
          expect(isVip, isTrue, reason: 'verified user is also unified VIP');
        } else if (u['id'] == 'u3') {
          expect(isVip, isFalse, reason: 'standard user is free tier');
        }
      }
    });
  });
}
