import 'package:loggy/loggy.dart';
import '../../../domain/entities/activity.dart';
import 'package:http/http.dart' as http;

import 'i_remote_activity_source.dart';

class RemoteActivitySource implements IActivitySource {
  final http.Client httpClient;

  RemoteActivitySource(this.httpClient);

  @override
  Future<List<Activity>> getActivitys() async {
    List<Activity> activitys = [];

    return Future.value(activitys);
  }

  @override
  Future<bool> addActivity(Activity activity) async {
    logInfo("Web service, Adding Activity $activity");
    return Future.value(true);
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    logInfo("Web service, Updating Activity with id $activity");
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivity(Activity activity) async {
    logInfo("Web service, Deleting Activity with id $activity");
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivitys() async {
    List<Activity> activitys = await getActivitys();
    for (var activity in activitys) {
      await deleteActivity(activity);
    }
    return Future.value(true);
  }
}
