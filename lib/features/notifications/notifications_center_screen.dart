import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/notification_service.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() => _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final NotificationService _service = NotificationService();
  List<DevotionalNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications 🔔'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/notifications/settings'),
            tooltip: 'Notification Preferences',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7A00)),
              )
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Color(0xFFFF7A00),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Notifications Yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daily shlokas, aarti alerts, and festival updates will appear here.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: const Color(0xFFFF7A00),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: Color(0xFFFF7A00),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                notif.body,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(notif.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (notif.actionUrl != null && notif.actionUrl!.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        if (notif.actionUrl!.contains('Wallpaper')) {
                                          context.push('/category/Wallpaper');
                                        } else if (notif.actionUrl!.contains('Bhajan')) {
                                          context.push('/category/Bhajan');
                                        } else {
                                          context.go('/home');
                                        }
                                      },
                                      child: const Text(
                                        'Explore 🚩',
                                        style: TextStyle(
                                          color: Color(0xFFFF7A00),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
