import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'other_service.g.dart';

class OtherServiceModel {
  final String value;

  OtherServiceModel({required this.value});

  OtherServiceModel copyWith({String? value}) {
    return OtherServiceModel(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtherServiceModel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

@riverpod
class OtherService extends _$OtherService {
  @override
  OtherServiceModel build() {
    ref.keepAlive();
    return OtherServiceModel(value: 'Initial Value');
  }

  void updateValue(String newValue) {
    state = state.copyWith(value: newValue);
  }
}

