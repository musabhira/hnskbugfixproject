// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends $NotifierProvider<ProfileRepository, ProfileRepository> {
  ProfileRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  ProfileRepository create() => ProfileRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'db1bc68e098184e550bd6ffa4ee16040b60af4b7';

abstract class _$ProfileRepository extends $Notifier<ProfileRepository> {
  ProfileRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileRepository, ProfileRepository>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileRepository, ProfileRepository>,
        ProfileRepository,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

final class UserProfileProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>?>,
        Map<String, dynamic>?,
        FutureOr<Map<String, dynamic>?>>
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  UserProfileProvider._(
      {required UserProfileFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'059431e30ed55f4b96dbdc92dab40539b8d6f2a2';

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>?>, String> {
  UserProfileFamily._()
      : super(
          retry: null,
          name: r'userProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserProfileProvider call(
    String userId,
  ) =>
      UserProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

@ProviderFor(userGallery)
final userGalleryProvider = UserGalleryFamily._();

final class UserGalleryProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  UserGalleryProvider._(
      {required UserGalleryFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userGalleryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userGalleryHash();

  @override
  String toString() {
    return r'userGalleryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return userGallery(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserGalleryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userGalleryHash() => r'fc41c455caf17bf63b8d064e770d1b8032a387e1';

final class UserGalleryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<Map<String, dynamic>>>,
            String> {
  UserGalleryFamily._()
      : super(
          retry: null,
          name: r'userGalleryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserGalleryProvider call(
    String userId,
  ) =>
      UserGalleryProvider._(argument: userId, from: this);

  @override
  String toString() => r'userGalleryProvider';
}

@ProviderFor(userThreads)
final userThreadsProvider = UserThreadsFamily._();

final class UserThreadsProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  UserThreadsProvider._(
      {required UserThreadsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userThreadsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userThreadsHash();

  @override
  String toString() {
    return r'userThreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return userThreads(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserThreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userThreadsHash() => r'a7618aded20fb010c3d12e3825262054d3f94a5d';

final class UserThreadsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<Map<String, dynamic>>>,
            String> {
  UserThreadsFamily._()
      : super(
          retry: null,
          name: r'userThreadsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserThreadsProvider call(
    String userId,
  ) =>
      UserThreadsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userThreadsProvider';
}

@ProviderFor(followCounts)
final followCountsProvider = FollowCountsFamily._();

final class FollowCountsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, int>>,
        Map<String, int>,
        FutureOr<Map<String, int>>>
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  FollowCountsProvider._(
      {required FollowCountsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'followCountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followCountsHash();

  @override
  String toString() {
    return r'followCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    final argument = this.argument as String;
    return followCounts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FollowCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followCountsHash() => r'8caf1419c6a574e48cffa068ac2c95c755b51de4';

final class FollowCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, int>>, String> {
  FollowCountsFamily._()
      : super(
          retry: null,
          name: r'followCountsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FollowCountsProvider call(
    String userId,
  ) =>
      FollowCountsProvider._(argument: userId, from: this);

  @override
  String toString() => r'followCountsProvider';
}

@ProviderFor(threadComments)
final threadCommentsProvider = ThreadCommentsFamily._();

final class ThreadCommentsProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  ThreadCommentsProvider._(
      {required ThreadCommentsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'threadCommentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$threadCommentsHash();

  @override
  String toString() {
    return r'threadCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return threadComments(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadCommentsHash() => r'7a405816cf9ca4e876201966c09c918bacfb9ce7';

final class ThreadCommentsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<Map<String, dynamic>>>,
            String> {
  ThreadCommentsFamily._()
      : super(
          retry: null,
          name: r'threadCommentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ThreadCommentsProvider call(
    String threadId,
  ) =>
      ThreadCommentsProvider._(argument: threadId, from: this);

  @override
  String toString() => r'threadCommentsProvider';
}
