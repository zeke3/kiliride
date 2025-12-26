// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sas_mobile/models/chatbot.model.dart';

// class ChatbotService {
//   static final ChatbotService _instance = ChatbotService._internal();
//   factory ChatbotService() => _instance;
//   ChatbotService._internal();

//   final String _baseUrl = dotenv.env['CHATBOT_BASE_URL'] ?? '';
//   final String _agentEndpoint = 'chatbot/demo_broker_agent/chat';

//   /// Sends a message to the chatbot and streams the response
//   /// Returns a Stream of ChatbotMessage that emits token-by-token
//   Stream<ChatbotMessage> sendMessageStream({
//     required String message,
//     required String sessionId,
//     required String userId,
//   }) async* {
//     if (_baseUrl.isEmpty) {
//       throw Exception('CHATBOT_BASE_URL not configured in .env file');
//     }

//     final url = Uri.parse('$_baseUrl/$_agentEndpoint');

//     final request = ChatbotRequest(
//       message: message,
//       sessionId: sessionId,
//       userId: userId,
//       stream: true,
//     );

//     try {
//       final client = http.Client();
//       final streamRequest = http.Request('POST', url);

//       streamRequest.headers['accept'] = 'application/json';
//       streamRequest.headers['Content-Type'] = 'application/json';
//       streamRequest.body = jsonEncode(request.toJson());

//       final streamedResponse = await client.send(streamRequest);

//       if (streamedResponse.statusCode != 200) {
//         throw Exception(
//           'Failed to send message: ${streamedResponse.statusCode}',
//         );
//       }

//       // Parse the SSE (Server-Sent Events) stream
//       await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
//         // Split by lines in case multiple events come in one chunk
//         final lines = chunk.split('\n');

//         for (final line in lines) {
//           if (line.trim().isEmpty) continue;

//           // SSE format: "data: {json}"
//           if (line.startsWith('data: ')) {
//             final jsonString = line.substring(6); // Remove "data: " prefix

//             try {
//               final jsonData = jsonDecode(jsonString);
//               final chatbotMessage = ChatbotMessage.fromJson(jsonData);
//               yield chatbotMessage;

//               // If done flag is true, we've received the complete message
//               if (chatbotMessage.done) {
//                 break;
//               }
//             } catch (e) {
//               debugPrint('Error parsing SSE message: $e');
//               debugPrint('Raw line: $line');
//             }
//           }
//         }
//       }

//       client.close();
//     } catch (e) {
//       debugPrint('Error in chatbot stream: $e');
//       throw Exception('Failed to communicate with chatbot: $e');
//     }
//   }

//   /// Sends a message to the chatbot and returns the complete response
//   /// This is a convenience method that waits for the entire stream to complete
//   Future<String> sendMessage({
//     required String message,
//     required String sessionId,
//     required String userId,
//   }) async {
//     final completeMessage = StringBuffer();

//     await for (final chunk in sendMessageStream(
//       message: message,
//       sessionId: sessionId,
//       userId: userId,
//     )) {
//       completeMessage.write(chunk.content);

//       if (chunk.done) {
//         break;
//       }
//     }

//     return completeMessage.toString();
//   }

//   /// Generates a unique session ID for the chat
//   String generateSessionId() {
//     return 'session_${DateTime.now().millisecondsSinceEpoch}';
//   }
// }
