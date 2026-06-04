import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../models/notification_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationViewModel>().add(const LoadNotifications());
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.orderAssigned:
      case NotificationType.orderOnTheWay:
      case NotificationType.orderDelivered:
        return Icons.shopping_bag_outlined;
      case NotificationType.subscriptionAssigned:
      case NotificationType.subscriptionDelivered:
        return Icons.autorenew_outlined;
      case NotificationType.bulkOrderAssigned:
      case NotificationType.bulkOrderDelivered:
        return Icons.business_outlined;
      case NotificationType.bottleCollectionAssigned:
      case NotificationType.bottleCollected:
        return Icons.recycling_outlined;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.orderAssigned:
      case NotificationType.orderOnTheWay:
        return PaalvandiTheme.outForDeliveryOrange;
      case NotificationType.orderDelivered:
      case NotificationType.subscriptionDelivered:
      case NotificationType.bulkOrderDelivered:
      case NotificationType.bottleCollected:
        return PaalvandiTheme.accentGreen;
      case NotificationType.subscriptionAssigned:
        return PaalvandiTheme.primaryBlue;
      case NotificationType.bulkOrderAssigned:
        return PaalvandiTheme.statusError;
      case NotificationType.bottleCollectionAssigned:
        return PaalvandiTheme.statusPending;
    }
  }

  void _showClearHistoryDialog(BuildContext context, Function scaleF, Function fs) {
    HapticService.medium();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
          ),
          backgroundColor: PaalvandiTheme.bgCream,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_sweep_outlined,
                  size: scaleF(40),
                  color: PaalvandiTheme.statusError,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Clear notification history?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'This action will permanently delete all notification records from your device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PaalvandiTheme.textDark,
                          side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PaalvandiTheme.statusError,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.heavy();
                          context.read<NotificationViewModel>().add(const ClearNotificationHistory());
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
          onPressed: () {
            HapticService.light();
            context.pop();
          },
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationViewModel, NotificationState>(
            builder: (context, state) {
              if (state.notifications.isEmpty || state.isLoading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: PaalvandiTheme.statusError),
                tooltip: 'Clear history',
                onPressed: () => _showClearHistoryDialog(context, scaleF, fs),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationViewModel, NotificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(hPadding),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(bottom: scaleF(12)),
                child: const SkeletonCard(),
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/noitemincart.json',
                    height: scaleF(120),
                  ),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'Your notification log is clear!',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(4)),
                  Text(
                    'Assignments and updates will show up here.',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      color: PaalvandiTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(), // Scroll bouncy back setup
            ),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
            itemBuilder: (context, index) {
              return _buildNotificationCard(context, state.notifications[index], scaleF, fs);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification item,
    Function scaleF,
    Function fs,
  ) {
    final cardColor = item.isRead
        ? PaalvandiTheme.cardWhite
        : PaalvandiTheme.primaryBlue.withOpacity(0.02);

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          HapticService.light();
          context.read<NotificationViewModel>().add(MarkNotificationRead(item.id));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(scaleF(16)),
        decoration: PaalvandiTheme.cardDecoration.copyWith(
          color: cardColor,
          border: Border.all(
            color: item.isRead ? PaalvandiTheme.cardBorderLight : PaalvandiTheme.primaryBlue,
            width: item.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Indicator
            Container(
              padding: EdgeInsets.all(scaleF(8)),
              decoration: BoxDecoration(
                color: _getColorForType(item.type).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(item.type),
                size: scaleF(20),
                color: _getColorForType(item.type),
              ),
            ),
            SizedBox(width: scaleF(14)),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12.5),
                            fontWeight: item.isRead ? FontWeight.bold : FontWeight.w900,
                            color: PaalvandiTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: scaleF(8),
                          height: scaleF(8),
                          decoration: const BoxDecoration(
                            color: PaalvandiTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: scaleF(4)),
                  Text(
                    item.message,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      height: 1.4,
                      color: item.isRead ? PaalvandiTheme.textSecondary : PaalvandiTheme.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),
                  Text(
                    _getRelativeTime(item.timestamp),
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
