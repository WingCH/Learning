import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        // 處理低效能版本的時間線
        final inefficientTimeline = driver.Timeline.fromJson(
          data['inefficient_scrolling'] as Map<String, dynamic>,
        );
        final inefficientSummary =
            driver.TimelineSummary.summarize(inefficientTimeline);

        // 儲存低效能版本的時間線和摘要
        await inefficientSummary.writeTimelineToFile(
          'inefficient_scrolling',
          pretty: true,
          includeSummary: true,
        );
      }
    },
  );
}
