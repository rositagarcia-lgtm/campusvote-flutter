class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SYSTEM_ALERT',
      title: json['title']?.toString() ?? 'Aviso',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      metadata:
          metadata is Map ? Map<String, dynamic>.from(metadata) : const {},
    );
  }
}
