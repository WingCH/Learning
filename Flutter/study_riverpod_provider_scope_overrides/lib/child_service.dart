import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_riverpod_provider_scope_overrides/root_service.dart';

part 'child_service.g.dart';

class ChildServiceModel {
  final String value;

  ChildServiceModel({required this.value});

  ChildServiceModel copyWith({String? value}) {
    return ChildServiceModel(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildServiceModel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

@Riverpod(dependencies: [RootService])
class ChildService extends _$ChildService {
  RootServiceModel get _rootServiceModel => ref.read(rootServiceProvider);
  @override
  ChildServiceModel build() {
    return ChildServiceModel(value: _rootServiceModel.value);
  }
}

