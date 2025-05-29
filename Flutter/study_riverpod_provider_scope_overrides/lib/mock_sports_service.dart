import 'package:study_riverpod_provider_scope_overrides/root_service.dart';

class MockRootService extends RootService {
  MockRootService();
  @override
  RootServiceModel build() {
    return RootServiceModel(
      value: 'Mock Value',
    );
  }
}
