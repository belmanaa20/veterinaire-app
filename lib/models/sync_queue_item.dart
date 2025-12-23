class SyncQueueItem {
  final int id;
  final String table;
  final String action; // 'insert', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int attempts;

  SyncQueueItem({
    required this.id,
    required this.table,
    required this.action,
    required this.data,
    required this.createdAt,
    this.attempts = 0,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as int,
      table: json['table'] as String,
      action: json['action'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      attempts: json['attempts'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table': table,
      'action': action,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'attempts': attempts,
    };
  }

  SyncQueueItem copyWith({
    int? id,
    String? table,
    String? action,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? attempts,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      table: table ?? this.table,
      action: action ?? this.action,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
    );
  }
}
