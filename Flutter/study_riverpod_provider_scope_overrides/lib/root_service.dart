import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_riverpod_provider_scope_overrides/child_service.dart';

part 'root_service.g.dart';

class RootServiceModel {
  final String value;

  RootServiceModel({required this.value});

  RootServiceModel copyWith({String? value}) {
    return RootServiceModel(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RootServiceModel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

@Riverpod(dependencies: [])
class RootService extends _$RootService {
  RootService();
  @override
  RootServiceModel build() {
    ref.keepAlive();
    return RootServiceModel(
      value: 'Initial Value',
    );
  }
}
