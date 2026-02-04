import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Notifications page showing app notifications.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = _mockNotifications[index];
          return _NotificationCard(notification: notification);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final color = notification.type == 'warning'
        ? AppColors.warning
        : notification.type == 'error'
            ? AppColors.error
            : notification.type == 'success'
                ? AppColors.success
                : AppColors.info;

    final icon = notification.type == 'warning'
        ? Icons.warning_amber
        : notification.type == 'error'
            ? Icons.error
            : notification.type == 'success'
                ? Icons.check_circle
                : Icons.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.surface
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final String type;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

const _mockNotifications = [
  _NotificationItem(
    title: 'Low SpO2 Alert',
    message:
        'Your oxygen saturation dropped below 92%. Please monitor closely.',
    time: '5 minutes ago',
    type: 'warning',
  ),
  _NotificationItem(
    title: 'Diagnosis Complete',
    message: 'Dr. Ahmed has reviewed your X-ray. View the results now.',
    time: '1 hour ago',
    type: 'success',
  ),
  _NotificationItem(
    title: 'Reminder',
    message: 'You have an upcoming appointment tomorrow at 10:00 AM.',
    time: '2 hours ago',
    type: 'info',
    isRead: true,
  ),
  _NotificationItem(
    title: 'Device Disconnected',
    message: 'Your monitoring device has been disconnected. Please reconnect.',
    time: 'Yesterday',
    type: 'error',
    isRead: true,
  ),
];
