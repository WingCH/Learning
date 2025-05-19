import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        // 處理優化版本的時間線
        final efficientTimeline = driver.Timeline.fromJson(
          data['efficient_scrolling'] as Map<String, dynamic>,
        );
        final efficientSummary =
            driver.TimelineSummary.summarize(efficientTimeline);

        // 儲存優化版本的時間線和摘要
        await efficientSummary.writeTimelineToFile(
          'efficient_scrolling',
          pretty: true,
          includeSummary: true,
        );
      }
    },
  );
}
