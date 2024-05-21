import 'package:untitled/dtos/application_data.dart';
import 'package:usage_stats/usage_stats.dart';

Future<Map<String, UsageInfo>> getCurrentUsageStats(
    Map<String, ApplicationData> appIds) async {
  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(const Duration(minutes: 3));

  Map<String, UsageInfo> queryAndAggregateUsageStats =
      await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

  List<String> keys = queryAndAggregateUsageStats.keys.toList();
  for (String key in keys) {
    if (!appIds.containsKey(key)) {
      queryAndAggregateUsageStats.remove(key);
    }
  }
  return queryAndAggregateUsageStats;
}

String? checkIfAnyAppHasBeenOpened(
    Map<String, UsageInfo> currentUsage,
    Map<String, UsageInfo> previousUsage,
    Map<String, ApplicationData> monitoredApplicationSet) {
  for (String appId in monitoredApplicationSet.keys) {
    if (currentUsage.containsKey(appId) && previousUsage.containsKey(appId)) {
      UsageInfo currentAppUsage = currentUsage[appId]!;
      UsageInfo previousAppUsage = previousUsage[appId]!;

      if (currentAppUsage.lastTimeUsed == previousAppUsage.lastTimeUsed) {
        if (currentAppUsage.totalTimeInForeground ==
            previousAppUsage.totalTimeInForeground) {
          return appId;
        }
      }
    }
  }

  return null;
}
