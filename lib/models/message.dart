enum MessageReceipt {
  sending,
  sent,
  delivered,
  read,
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageReceipt receipt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.receipt = MessageReceipt.sent,
    this.deliveredAt,
    this.readAt,
  });

  bool get isRead => receipt == MessageReceipt.read;
  bool get isDelivered => receipt == MessageReceipt.delivered || receipt == MessageReceipt.read;

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    MessageReceipt? receipt,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      receipt: receipt ?? this.receipt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'receipt': receipt.name,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'readAt': readAt?.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final receiptStr = map['receipt'] as String? ?? 'sent';
    final receipt = MessageReceipt.values.firstWhere(
      (e) => e.name == receiptStr,
      orElse: () => MessageReceipt.sent,
    );

    return Message(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
      receipt: receipt,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'] as int)
          : null,
      readAt: map['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['readAt'] as int)
          : null,
    );
  }
}
