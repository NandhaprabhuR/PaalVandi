import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String category; // 'delivery' | 'subscription' | 'wallet' | 'payment' | 'offer'
  final String icon;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.icon,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _isLocalLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Milk Delivered 🥛',
      body: 'Your fresh milk bottle was delivered at 6:15 AM today.',
      category: 'delivery',
      icon: '🥛',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Subscription Expiring ⚠️',
      body: 'Your Family subscription is expiring in 2 days. Renew now to avoid interruption.',
      category: 'subscription',
      icon: '⚠️',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Bottle Return Approved ♻',
      body: 'Bottle return verified. ₹40 refund credited to your bottle wallet.',
      category: 'wallet',
      icon: '♻',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Payment Successful 💳',
      body: 'Payment of ₹350 for Order #F2K8X successful.',
      category: 'payment',
      icon: '💳',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Special Offers 🎁',
      body: 'Get 10% off your next smart subscription renewal today!',
      category: 'offer',
      icon: '🎁',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications marked as read',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: CustomersLoginThemeView.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'delivery':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'subscription':
        return const Color(0xFFFFF3E0); // Light Orange
      case 'wallet':
        return const Color(0xFFE8F5E9); // Light Green
      case 'payment':
        return const Color(0xFFF3E5F5); // Light Purple
      case 'offer':
        return const Color(0xFFFFFDE7); // Light Yellow
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: _notifications.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.mark_chat_read_outlined, color: CustomersLoginThemeView.primaryBlue),
                  tooltip: 'Mark all as read',
                  onPressed: _markAllAsRead,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                  tooltip: 'Clear all',
                  onPressed: () async {
                    final confirmed = await showPaalvandiConfirmDialog(
                      context,
                      title: 'Clear All?',
                      message: 'Are you sure you want to clear all notifications?',
                      noLabel: 'Cancel',
                      yesLabel: 'Clear',
                    );
                    if (confirmed == true && mounted) {
                      _clearAll();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: _isLocalLoading
          ? _buildNotificationsSkeleton(context, hPadding, scaleF, fs)
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🔔',
                    style: TextStyle(fontSize: 64),
                  ),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'All Caught Up!',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(18),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(6)),
                  Text(
                    'No new notifications at the moment.',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.w500,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: scaleF(20)),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (_) {
                    _deleteNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification cleared',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                        ),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _notifications.insert(index, notification);
                            });
                          },
                        ),
                        backgroundColor: CustomersLoginThemeView.textDark,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: scaleF(12)),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.white : const Color(0xFFF2F7FC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          notification.isRead = true;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(scaleF(16)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: scaleF(44),
                              height: scaleF(44),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(notification.category),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                notification.icon,
                                style: TextStyle(fontSize: fs(20)),
                              ),
                            ),
                            SizedBox(width: scaleF(14)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(14),
                                            fontWeight: notification.isRead
                                                ? FontWeight.w700
                                                : FontWeight.w900,
                                            color: CustomersLoginThemeView.textDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatTimestamp(notification.timestamp),
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(10),
                                          fontWeight: FontWeight.bold,
                                          color: CustomersLoginThemeView.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: scaleF(6)),
                                  Text(
                                    notification.body,
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(12),
                                      fontWeight: notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                      color: notification.isRead
                                          ? CustomersLoginThemeView.textGrey
                                          : CustomersLoginThemeView.textDark.withOpacity(0.85),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNotificationsSkeleton(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: scaleF(10)),
          padding: EdgeInsets.all(scaleF(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton(width: scaleF(40), height: scaleF(40), borderRadius: 20),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerSkeleton(width: scaleF(120), height: scaleF(13), borderRadius: 3),
                        ShimmerSkeleton(width: scaleF(40), height: scaleF(9), borderRadius: 2),
                      ],
                    ),
                    SizedBox(height: scaleF(8)),
                    ShimmerSkeleton(width: double.infinity, height: scaleF(11), borderRadius: 2),
                    SizedBox(height: scaleF(4)),
                    ShimmerSkeleton(width: scaleF(180), height: scaleF(11), borderRadius: 2),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
