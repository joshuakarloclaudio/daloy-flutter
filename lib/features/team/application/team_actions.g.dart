// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes to the team. Each throws `ApiException` for the screen to show,
/// and refreshes what the screen is looking at when it succeeds.

@ProviderFor(TeamActions)
final teamActionsProvider = TeamActionsProvider._();

/// Changes to the team. Each throws `ApiException` for the screen to show,
/// and refreshes what the screen is looking at when it succeeds.
final class TeamActionsProvider extends $NotifierProvider<TeamActions, void> {
  /// Changes to the team. Each throws `ApiException` for the screen to show,
  /// and refreshes what the screen is looking at when it succeeds.
  TeamActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamActionsHash();

  @$internal
  @override
  TeamActions create() => TeamActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$teamActionsHash() => r'18818d41d9a87b79383bbf7d3a30a5f508306c4e';

/// Changes to the team. Each throws `ApiException` for the screen to show,
/// and refreshes what the screen is looking at when it succeeds.

abstract class _$TeamActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
