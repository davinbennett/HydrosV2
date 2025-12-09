import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import '../../../core/themes/font_size.dart';
import '../../../core/themes/font_weight.dart';
import '../../providers/notification_provider.dart';

class NotificationPopup {
  static OverlayEntry? _overlay;

  static void show(BuildContext context) {
    if (_overlay != null) return;

    final overlay = Overlay.of(context);

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // TAP AREA GELAP UNTUK TUTUP
            GestureDetector(
              onTap: hide,
              child: Container(color: Colors.transparent),
            ),

            // POPUP BOX
            Positioned(top: 95, right: 12, child: _PopupContent()),
          ],
        );
      },
    );

    overlay.insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}

class _PopupContent extends ConsumerWidget {
  String getNotifTitle(Map item) {
    return item["title"] ?? item["Title"] ?? "";
  }

  String getNotifBody(Map item) {
    return item["body"] ?? item["Body"] ?? "";
  }

  bool getNotifIsRead(Map item) {
    return item["is_read"] ?? item["IsRead"] ?? false;
  }

  int getNotifId(Map<String, dynamic> item) {
    final raw =
        item["id"] ??
        item["ID"] ??
        item["notification_id"] ??
        item["NotificationID"] ??
        0;

    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;

    return 0;
  }

  String formatNotifTime(dynamic raw) {
    if (raw == null) return "";

    try {
      final dt = DateTime.parse(raw.toString()).toLocal();

      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return "$day/$month $hour:$minute";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    final list = state.listNotification;

    return Material(
      borderRadius: BorderRadius.circular(AppRadius.rl),
      elevation: 1,
      child: Container(
        constraints: BoxConstraints(maxHeight: 420),
        width: 320,
        padding: EdgeInsets.only(bottom: AppSpacingSize.l),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.rl),
        ),
        child:
            state.isLoading
                ? Padding(
                  padding: EdgeInsets.all(AppSpacingSize.m),
                  child: Center(child: CircularProgressIndicator()),
                )
                : list.isEmpty
                ? Padding(
                  padding: EdgeInsets.only(top: AppSpacingSize.l),
                  child: Center(child: Text("No Notification")),
                )
                : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final item = list[i];

                      final notifId = getNotifId(item);
                      final title = getNotifTitle(item);
                      final body = getNotifBody(item);
                      final isRead = getNotifIsRead(item);
                      final timeText = formatNotifTime(item["created_at"]);

                      return Dismissible(
                        key: ValueKey<int>(getNotifId(item)),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          final id = getNotifId(item);
                          notifier.removeFromLocal(id);
                          await notifier.deleteNotification(id);
                          return true;
                        },

                        background: Container(
                          padding: EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            onTap: () {
                              notifier.readNotification(notifId);
                            },
                            leading: Icon(
                              isRead
                                  ? Icons.notifications
                                  : Icons.notifications_active,
                              color: isRead ? Colors.grey : Colors.orange,
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight:
                                    isRead
                                        ? AppFontWeight.normal
                                        : AppFontWeight.semiBold,
                                fontSize: AppFontSize.m,
                              ),
                            ),
                            subtitle: Text(
                              body,
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                            trailing: Text(
                              timeText,
                              style: TextStyle(
                                fontSize: AppFontSize.xs,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
