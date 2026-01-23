// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveUsers)
final activeUsersProvider = ActiveUsersFamily._();

final class ActiveUsersProvider
    extends $AsyncNotifierProvider<ActiveUsers, ActiveUsersData> {
  ActiveUsersProvider._(
      {required ActiveUsersFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'activeUsersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeUsersHash();

  @override
  String toString() {
    return r'activeUsersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveUsers create() => ActiveUsers();

  @override
  bool operator ==(Object other) {
    return other is ActiveUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeUsersHash() => r'b356ea4764af6495ded320c364ad1904bdb9ea89';

final class ActiveUsersFamily extends $Family
    with
        $ClassFamilyOverride<ActiveUsers, AsyncValue<ActiveUsersData>,
            ActiveUsersData, FutureOr<ActiveUsersData>, String> {
  ActiveUsersFamily._()
      : super(
          retry: null,
          name: r'activeUsersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ActiveUsersProvider call(
    String profileId,
  ) =>
      ActiveUsersProvider._(argument: profileId, from: this);

  @override
  String toString() => r'activeUsersProvider';
}

abstract class _$ActiveUsers extends $AsyncNotifier<ActiveUsersData> {
  late final _$args = ref.$arg as String;
  String get profileId => _$args;

  FutureOr<ActiveUsersData> build(
    String profileId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ActiveUsersData>, ActiveUsersData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ActiveUsersData>, ActiveUsersData>,
        AsyncValue<ActiveUsersData>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
