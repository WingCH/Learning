import 'package:study_riverpod_provider_scope_overrides/sports_service.dart';

class MockSportsService extends SportsService {
  MockSportsService();
  @override
  SportsServiceModel build() {
    return SportsServiceModel(
      sport: 'Mock Sport',
      description: 'This is a mock sports service.',
      otherValue: 'Mock Other Value',
    );
  }
}
