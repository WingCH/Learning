// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$childServiceHash() => r'b068336d67cdd72453b4422a3a7583950588ba59';

/// See also [ChildService].
@ProviderFor(ChildService)
final childServiceProvider =
    AutoDisposeNotifierProvider<ChildService, ChildServiceModel>.internal(
  ChildService.new,
  name: r'childServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$childServiceHash,
  dependencies: <ProviderOrFamily>[rootServiceProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    rootServiceProvider,
    ...?rootServiceProvider.allTransitiveDependencies
  },
);

typedef _$ChildService = AutoDisposeNotifier<ChildServiceModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
