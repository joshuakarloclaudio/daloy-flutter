// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamService)
final teamServiceProvider = TeamServiceProvider._();

final class TeamServiceProvider
    extends $FunctionalProvider<TeamService, TeamService, TeamService>
    with $Provider<TeamService> {
  TeamServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamServiceHash();

  @$internal
  @override
  $ProviderElement<TeamService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TeamService create(Ref ref) {
    return teamService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamService>(value),
    );
  }
}

String _$teamServiceHash() => r'54b1f7f03c7961cceb109478be60dbc3ebb0f4b6';

/// Members and pending invitations of the active workspace.

@ProviderFor(teamRoster)
final teamRosterProvider = TeamRosterProvider._();

/// Members and pending invitations of the active workspace.

final class TeamRosterProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamRoster>,
          TeamRoster,
          FutureOr<TeamRoster>
        >
    with $FutureModifier<TeamRoster>, $FutureProvider<TeamRoster> {
  /// Members and pending invitations of the active workspace.
  TeamRosterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamRosterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamRosterHash();

  @$internal
  @override
  $FutureProviderElement<TeamRoster> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TeamRoster> create(Ref ref) {
    return teamRoster(ref);
  }
}

String _$teamRosterHash() => r'dab46df57c7f672e1f098c0d9aaa8658822e1af1';

@ProviderFor(workspaceJoinLink)
final workspaceJoinLinkProvider = WorkspaceJoinLinkProvider._();

final class WorkspaceJoinLinkProvider
    extends
        $FunctionalProvider<AsyncValue<JoinLink>, JoinLink, FutureOr<JoinLink>>
    with $FutureModifier<JoinLink>, $FutureProvider<JoinLink> {
  WorkspaceJoinLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceJoinLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceJoinLinkHash();

  @$internal
  @override
  $FutureProviderElement<JoinLink> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<JoinLink> create(Ref ref) {
    return workspaceJoinLink(ref);
  }
}

String _$workspaceJoinLinkHash() => r'765f12c6708a93ebabbf93a26c1abb8cb029b55c';
