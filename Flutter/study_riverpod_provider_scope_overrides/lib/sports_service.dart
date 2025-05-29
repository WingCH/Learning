import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:study_riverpod_provider_scope_overrides/other_service.dart';

part 'sports_service.g.dart';

class SportsServiceModel {
  final String sport;
  final String description;
  final String otherValue;

  SportsServiceModel({required this.sport, required this.description, required this.otherValue});

  SportsServiceModel copyWith({String? sport, String? description, String? otherValue}) {
    return SportsServiceModel(
      sport: sport ?? this.sport,
      description: description ?? this.description,
      otherValue: otherValue ?? this.otherValue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportsServiceModel &&
          runtimeType == other.runtimeType &&
          sport == other.sport &&
          description == other.description &&
          otherValue == other.otherValue;

  @override
  int get hashCode => sport.hashCode ^ description.hashCode ^ otherValue.hashCode;
}

@riverpod
class SportsService extends _$SportsService {
  SportsService();
  @override
  SportsServiceModel build() {
    ref.keepAlive();
    final otherData = ref.watch(otherServiceProvider);
    return SportsServiceModel(
      sport: 'Basketball ${otherData.value}',
      description: 'A team sport played with a ball and hoop.',
      otherValue: otherData.value,
    );
  }

  void updateSport(String newSport) {
    state = state.copyWith(sport: newSport);
  }

  void updateDescription(String newDescription) {
    state = state.copyWith(description: newDescription);
  }
}
