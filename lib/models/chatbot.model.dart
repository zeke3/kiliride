class ChatbotMessage {
  final String content;
  final String sessionId;
  final bool done;

  ChatbotMessage({
    required this.content,
    required this.sessionId,
    required this.done,
  });

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      content: json['content'] ?? '',
      sessionId: json['session_id'] ?? '',
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'session_id': sessionId,
      'done': done,
    };
  }
}

class ChatbotRequest {
  final String message;
  final String sessionId;
  final String userId;
  final bool stream;

  ChatbotRequest({
    required this.message,
    required this.sessionId,
    required this.userId,
    this.stream = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'session_id': sessionId,
      'user_id': userId,
      'stream': stream,
    };
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
