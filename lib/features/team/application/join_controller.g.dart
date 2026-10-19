// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the link offers — fetched without signing in.

@ProviderFor(joinPreview)
final joinPreviewProvider = JoinPreviewFamily._();

/// What the link offers — fetched without signing in.

final class JoinPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<JoinPreview>,
          JoinPreview,
          FutureOr<JoinPreview>
        >
    with $FutureModifier<JoinPreview>, $FutureProvider<JoinPreview> {
  /// What the link offers — fetched without signing in.
  JoinPreviewProvider._({
    required JoinPreviewFamily super.from,
    required (JoinKind, String) super.argument,
  }) : super(
         retry: null,
         name: r'joinPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$joinPreviewHash();

  @override
  String toString() {
    return r'joinPreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<JoinPreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<JoinPreview> create(Ref ref) {
    final argument = this.argument as (JoinKind, String);
    return joinPreview(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$joinPreviewHash() => r'8ce73e071bcbc9f74c2511bbe879267f006cdaf3';

/// What the link offers — fetched without signing in.

final class JoinPreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<JoinPreview>, (JoinKind, String)> {
  JoinPreviewFamily._()
    : super(
        retry: null,
        name: r'joinPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the link offers — fetched without signing in.

  JoinPreviewProvider call(JoinKind kind, String token) =>
      JoinPreviewProvider._(argument: (kind, token), from: this);

  @override
  String toString() => r'joinPreviewProvider';
}

/// Accepting it: joins the workspace, makes it the active one.

@ProviderFor(JoinActions)
final joinActionsProvider = JoinActionsProvider._();

/// Accepting it: joins the workspace, makes it the active one.
final class JoinActionsProvider extends $NotifierProvider<JoinActions, void> {
  /// Accepting it: joins the workspace, makes it the active one.
  JoinActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinActionsHash();

  @$internal
  @override
  JoinActions create() => JoinActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$joinActionsHash() => r'b26cd90e6956262839553776e9cca7612c66e8d5';

/// Accepting it: joins the workspace, makes it the active one.

abstract class _$JoinActions extends $Notifier<void> {
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
