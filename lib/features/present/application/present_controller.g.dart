// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'present_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How slides look on this device: theme, font, size, lines per slide.
/// Kept across sessions (the web keeps them in localStorage).

@ProviderFor(PresentLookController)
final presentLookControllerProvider = PresentLookControllerProvider._();

/// How slides look on this device: theme, font, size, lines per slide.
/// Kept across sessions (the web keeps them in localStorage).
final class PresentLookControllerProvider
    extends $NotifierProvider<PresentLookController, PresentLook> {
  /// How slides look on this device: theme, font, size, lines per slide.
  /// Kept across sessions (the web keeps them in localStorage).
  PresentLookControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentLookControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentLookControllerHash();

  @$internal
  @override
  PresentLookController create() => PresentLookController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresentLook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresentLook>(value),
    );
  }
}

String _$presentLookControllerHash() =>
    r'76fea0658260415d4642493aa06b7034f6c524f8';

/// How slides look on this device: theme, font, size, lines per slide.
/// Kept across sessions (the web keeps them in localStorage).

abstract class _$PresentLookController extends $Notifier<PresentLook> {
  PresentLook build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PresentLook, PresentLook>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PresentLook, PresentLook>,
              PresentLook,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Where the room is: the slide on the wall (found again when slides are
/// rebuilt) and whether the screen is blanked. Kept apart from
/// [PresentDeckController], which rebuilds on every Drift write.

@ProviderFor(PresentCursor)
final presentCursorProvider = PresentCursorFamily._();

/// Where the room is: the slide on the wall (found again when slides are
/// rebuilt) and whether the screen is blanked. Kept apart from
/// [PresentDeckController], which rebuilds on every Drift write.
final class PresentCursorProvider
    extends
        $NotifierProvider<
          PresentCursor,
          ({PresentSlide? at, bool blanked, int index})
        > {
  /// Where the room is: the slide on the wall (found again when slides are
  /// rebuilt) and whether the screen is blanked. Kept apart from
  /// [PresentDeckController], which rebuilds on every Drift write.
  PresentCursorProvider._({
    required PresentCursorFamily super.from,
    required PerformSource super.argument,
  }) : super(
         retry: null,
         name: r'presentCursorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presentCursorHash();

  @override
  String toString() {
    return r'presentCursorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PresentCursor create() => PresentCursor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({PresentSlide? at, bool blanked, int index}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({PresentSlide? at, bool blanked, int index})>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PresentCursorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presentCursorHash() => r'0ca375814e65a36831bf23c4877881150ddf3aec';

/// Where the room is: the slide on the wall (found again when slides are
/// rebuilt) and whether the screen is blanked. Kept apart from
/// [PresentDeckController], which rebuilds on every Drift write.

final class PresentCursorFamily extends $Family
    with
        $ClassFamilyOverride<
          PresentCursor,
          ({PresentSlide? at, bool blanked, int index}),
          ({PresentSlide? at, bool blanked, int index}),
          ({PresentSlide? at, bool blanked, int index}),
          PerformSource
        > {
  PresentCursorFamily._()
    : super(
        retry: null,
        name: r'presentCursorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Where the room is: the slide on the wall (found again when slides are
  /// rebuilt) and whether the screen is blanked. Kept apart from
  /// [PresentDeckController], which rebuilds on every Drift write.

  PresentCursorProvider call(PerformSource source) =>
      PresentCursorProvider._(argument: source, from: this);

  @override
  String toString() => r'presentCursorProvider';
}

/// Where the room is: the slide on the wall (found again when slides are
/// rebuilt) and whether the screen is blanked. Kept apart from
/// [PresentDeckController], which rebuilds on every Drift write.

abstract class _$PresentCursor
    extends $Notifier<({PresentSlide? at, bool blanked, int index})> {
  late final _$args = ref.$arg as PerformSource;
  PerformSource get source => _$args;

  ({PresentSlide? at, bool blanked, int index}) build(PerformSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({PresentSlide? at, bool blanked, int index}),
              ({PresentSlide? at, bool blanked, int index})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({PresentSlide? at, bool blanked, int index}),
                ({PresentSlide? at, bool blanked, int index})
              >,
              ({PresentSlide? at, bool blanked, int index}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The deck for a line-up (its keys and section order) or a single song —
/// built from what's on this device, so it presents offline. Every control
/// surface (touch, pedal, a paired remote) goes through [apply].

@ProviderFor(PresentDeckController)
final presentDeckControllerProvider = PresentDeckControllerFamily._();

/// The deck for a line-up (its keys and section order) or a single song —
/// built from what's on this device, so it presents offline. Every control
/// surface (touch, pedal, a paired remote) goes through [apply].
final class PresentDeckControllerProvider
    extends $NotifierProvider<PresentDeckController, PresentView> {
  /// The deck for a line-up (its keys and section order) or a single song —
  /// built from what's on this device, so it presents offline. Every control
  /// surface (touch, pedal, a paired remote) goes through [apply].
  PresentDeckControllerProvider._({
    required PresentDeckControllerFamily super.from,
    required PerformSource super.argument,
  }) : super(
         retry: null,
         name: r'presentDeckControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presentDeckControllerHash();

  @override
  String toString() {
    return r'presentDeckControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PresentDeckController create() => PresentDeckController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresentView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresentView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PresentDeckControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presentDeckControllerHash() =>
    r'b1f0474a08c7be873ed74d9494773e5d016f39fb';

/// The deck for a line-up (its keys and section order) or a single song —
/// built from what's on this device, so it presents offline. Every control
/// surface (touch, pedal, a paired remote) goes through [apply].

final class PresentDeckControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PresentDeckController,
          PresentView,
          PresentView,
          PresentView,
          PerformSource
        > {
  PresentDeckControllerFamily._()
    : super(
        retry: null,
        name: r'presentDeckControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The deck for a line-up (its keys and section order) or a single song —
  /// built from what's on this device, so it presents offline. Every control
  /// surface (touch, pedal, a paired remote) goes through [apply].

  PresentDeckControllerProvider call(PerformSource source) =>
      PresentDeckControllerProvider._(argument: source, from: this);

  @override
  String toString() => r'presentDeckControllerProvider';
}

/// The deck for a line-up (its keys and section order) or a single song —
/// built from what's on this device, so it presents offline. Every control
/// surface (touch, pedal, a paired remote) goes through [apply].

abstract class _$PresentDeckController extends $Notifier<PresentView> {
  late final _$args = ref.$arg as PerformSource;
  PerformSource get source => _$args;

  PresentView build(PerformSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PresentView, PresentView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PresentView, PresentView>,
              PresentView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
