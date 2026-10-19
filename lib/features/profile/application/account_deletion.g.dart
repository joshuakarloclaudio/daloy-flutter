// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deletion.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What deleting the account would involve, asked of the server each time the
/// sheet opens so it never goes stale.

@ProviderFor(accountDeletionPreview)
final accountDeletionPreviewProvider = AccountDeletionPreviewProvider._();

/// What deleting the account would involve, asked of the server each time the
/// sheet opens so it never goes stale.

final class AccountDeletionPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountDeletionPreview>,
          AccountDeletionPreview,
          FutureOr<AccountDeletionPreview>
        >
    with
        $FutureModifier<AccountDeletionPreview>,
        $FutureProvider<AccountDeletionPreview> {
  /// What deleting the account would involve, asked of the server each time the
  /// sheet opens so it never goes stale.
  AccountDeletionPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDeletionPreviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDeletionPreviewHash();

  @$internal
  @override
  $FutureProviderElement<AccountDeletionPreview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountDeletionPreview> create(Ref ref) {
    return accountDeletionPreview(ref);
  }
}

String _$accountDeletionPreviewHash() =>
    r'3932bdf844b2ac3324150af07956fe94f7a0ec41';
