import 'package:flutter_test/flutter_test.dart';
import 'package:study_mockito/version_helper.dart';

void main() {
  group('VersionHelper', () {
    test('isVersionGreaterThan 正確比較版本號', () {
      expect(VersionHelper.isVersionGreaterThan('1.2.3', '1.2.0'), true);
      expect(VersionHelper.isVersionGreaterThan('1.10.0', '1.2.0'), true);
      expect(VersionHelper.isVersionGreaterThan('2.0.0', '1.9.9'), true);
      expect(VersionHelper.isVersionGreaterThan('1.2.3', '1.2.3'), false);
      expect(VersionHelper.isVersionGreaterThan('1.2.0', '1.2.3'), false);
      expect(VersionHelper.isVersionGreaterThan('1.0.0', '1.0.1'), false);
    });

    test('isVersionGreaterThan 處理不同長度的版本號', () {
      expect(VersionHelper.isVersionGreaterThan('1.2.3.4', '1.2.3'), true);
      expect(VersionHelper.isVersionGreaterThan('1.2.3', '1.2.3.0'), false);
      expect(VersionHelper.isVersionGreaterThan('1.2', '1.2.0'), false);
      expect(VersionHelper.isVersionGreaterThan('1.2.0.1', '1.2'), true);
    });
  });
}
