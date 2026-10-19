// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
/// the click is a separate switch, so the chart can move with the metronome
/// muted. Per device, never sent to a live session.
///
/// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
/// so the click is sample-accurate; the screen hears about each beat when it
/// sounds, through [beat].

@ProviderFor(PracticeController)
final practiceControllerProvider = PracticeControllerFamily._();

/// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
/// the click is a separate switch, so the chart can move with the metronome
/// muted. Per device, never sent to a live session.
///
/// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
/// so the click is sample-accurate; the screen hears about each beat when it
/// sounds, through [beat].
final class PracticeControllerProvider
    extends $NotifierProvider<PracticeController, PracticeState> {
  /// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
  /// the click is a separate switch, so the chart can move with the metronome
  /// muted. Per device, never sent to a live session.
  ///
  /// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
  /// so the click is sample-accurate; the screen hears about each beat when it
  /// sounds, through [beat].
  PracticeControllerProvider._({
    required PracticeControllerFamily super.from,
    required PerformSource super.argument,
  }) : super(
         retry: null,
         name: r'practiceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$practiceControllerHash();

  @override
  String toString() {
    return r'practiceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PracticeController create() => PracticeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PracticeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PracticeState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PracticeControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$practiceControllerHash() =>
    r'a1bafd09b78ffcd58eddbab3c0f29fad876d4f55';

/// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
/// the click is a separate switch, so the chart can move with the metronome
/// muted. Per device, never sent to a live session.
///
/// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
/// so the click is sample-accurate; the screen hears about each beat when it
/// sounds, through [beat].

final class PracticeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PracticeController,
          PracticeState,
          PracticeState,
          PracticeState,
          PerformSource
        > {
  PracticeControllerFamily._()
    : super(
        retry: null,
        name: r'practiceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
  /// the click is a separate switch, so the chart can move with the metronome
  /// muted. Per device, never sent to a live session.
  ///
  /// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
  /// so the click is sample-accurate; the screen hears about each beat when it
  /// sounds, through [beat].

  PracticeControllerProvider call(PerformSource source) =>
      PracticeControllerProvider._(argument: source, from: this);

  @override
  String toString() => r'practiceControllerProvider';
}

/// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
/// the click is a separate switch, so the chart can move with the metronome
/// muted. Per device, never sent to a live session.
///
/// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
/// so the click is sample-accurate; the screen hears about each beat when it
/// sounds, through [beat].

abstract class _$PracticeController extends $Notifier<PracticeState> {
  late final _$args = ref.$arg as PerformSource;
  PerformSource get source => _$args;

  PracticeState build(PerformSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PracticeState, PracticeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PracticeState, PracticeState>,
              PracticeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
