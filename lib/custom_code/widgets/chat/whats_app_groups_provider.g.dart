// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whats_app_groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  SupabaseClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'supabaseClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'97279662e25452b84ad903f5fa9dfb7a48a7c358';

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

final class CurrentUserIdProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  CurrentUserIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentUserIdHash() => r'9007acf0c3a1a7f186761f214ebca10669528e01';

@ProviderFor(currentProfileId)
final currentProfileIdProvider = CurrentProfileIdProvider._();

final class CurrentProfileIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentProfileIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentProfileIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentProfileIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentProfileId(ref);
  }
}

String _$currentProfileIdHash() => r'24635d7dcbd7c75d12ebaf63f51d36db672de15d';

@ProviderFor(Conversations)
final conversationsProvider = ConversationsProvider._();

final class ConversationsProvider
    extends $AsyncNotifierProvider<Conversations, List<ChatConversation>> {
  ConversationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'conversationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$conversationsHash();

  @$internal
  @override
  Conversations create() => Conversations();
}

String _$conversationsHash() => r'd6d663a7995683d777c822b12232cf731f3b1a90';

abstract class _$Conversations extends $AsyncNotifier<List<ChatConversation>> {
  FutureOr<List<ChatConversation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<ChatConversation>>, List<ChatConversation>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ChatConversation>>, List<ChatConversation>>,
        AsyncValue<List<ChatConversation>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
