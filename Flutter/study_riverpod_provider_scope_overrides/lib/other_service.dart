import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class OtherService extends AutoDisposeNotifier<OtherServiceModel> {
  @override
  OtherServiceModel build() {
    return OtherServiceModel(value: 'Initial Value');
  }

  void updateValue(String newValue) {
    state = state.copyWith(value: newValue);
  }
}

final otherProvider = AutoDisposeNotifierProvider<OtherService, OtherServiceModel>(() => OtherService());
