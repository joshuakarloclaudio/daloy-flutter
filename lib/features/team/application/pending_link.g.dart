// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_link.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A join or invitation link the user opened before they could use it
/// (signed out, or with no workspace yet). Held until they're in, then opened.

@ProviderFor(PendingLink)
final pendingLinkProvider = PendingLinkProvider._();

/// A join or invitation link the user opened before they could use it
/// (signed out, or with no workspace yet). Held until they're in, then opened.
final class PendingLinkProvider
    extends $NotifierProvider<PendingLink, String?> {
  /// A join or invitation link the user opened before they could use it
  /// (signed out, or with no workspace yet). Held until they're in, then opened.
  PendingLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingLinkHash();

  @$internal
  @override
  PendingLink create() => PendingLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingLinkHash() => r'1a5117bf3309ffdfc09f38b4caca1206a0ccd423';

/// A join or invitation link the user opened before they could use it
/// (signed out, or with no workspace yet). Held until they're in, then opened.

abstract class _$PendingLink extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
