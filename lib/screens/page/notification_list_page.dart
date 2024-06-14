import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notification_service.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  List<ActiveNotification> notifications = [];

  @override
  void initState() {
    super.initState();

    //저장된 데이터 가져오기 위해 이걸 사용
    loadSavedNotifications();
    // 알림 목록을 가져오는 로직 추가
    fetchActiveNotifications();
  }

  Future<void> loadSavedNotifications() async {
    final savedNotifications =
        await FlutterLocalNotification.getSavedNotifications();
    setState(() {
      notifications = savedNotifications;
    });
  }

  Future<void> saveNotifications() async {
    await FlutterLocalNotification.saveNotifications(notifications);
  }

  Future<void> fetchActiveNotifications() async {
    final activeNotifications =
        await FlutterLocalNotification.getActiveNotifications();
    setState(() {
      notifications = activeNotifications ?? [];
    });
    await saveNotifications();
  }

  void clearNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  var title = "알림";
  double size = 35;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          // Column 대신 ListView 사용
          padding: const EdgeInsets.all(25.0),
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Text(
                  '알림 목록',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: clearNotifications,
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.body ?? ''),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// return Scaffold(
//   appBar: AppBar(
//     title: const Text('알림 목록'),
//     actions: [
//       IconButton(
//         icon: const Icon(Icons.delete),
//         onPressed: clearNotifications,
//       ),
//     ],
//   ),
//   body: ListView.builder(
//     itemCount: notifications.length,
//     itemBuilder: (context, index) {
//       final notification = notifications[index];
//       return ListTile(
//         title: Text(notification.title ?? ''),
//         subtitle: Text(notification.body ?? ''),
//       );
//     },
//   ),
// );
