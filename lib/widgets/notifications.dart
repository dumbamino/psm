// lib/service/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    // Initialize awesome notifications
    await AwesomeNotifications().initialize(
      // Use 'resource://drawable/res_app_icon' if you placed an icon named 'res_app_icon.png'
      // in the android/app/src/main/res/drawable folder.
      // Otherwise, set it to null to use the default app icon.
        'resource://drawable/app_icon',
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic app alerts',
            defaultColor: Colors.teal,
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            channelShowBadge: true,
          ),
        ],
        // Optional: Channel groups for organization
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group',
          )
        ],
        debug: true);

    // Request permission to send notifications if not already allowed
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Listens for notification actions
  static void configureListeners() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod);
  }

  /// Method to trigger a simple notification
  static Future<void> showBasicNotification({
    required int id,
    required String title,
    required String body,
    String? summary,
    Map<String, String>? payload,
    String? largeIcon,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        summary: summary,
        payload: payload,
        largeIcon: largeIcon,
        notificationLayout: largeIcon != null ? NotificationLayout.BigPicture : NotificationLayout.Default,
      ),
    );
  }
}


/// Controller class to handle notification events in the background.
class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    // Here, you can add navigation logic based on the payload.
    // For example, if the payload contains a route, you can navigate to it.
    // Note: This runs in a background isolate. Direct navigation is tricky.
    // A common approach is to use a stream or other state management solution
    // to communicate the navigation event to the main app.
  }
}