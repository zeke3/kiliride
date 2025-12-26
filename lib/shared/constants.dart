import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseUrl = dotenv.env['BASE_URL']!;
String googleMapApiKey = dotenv.env['MAP_API_KEY']!;
String xApiKey = dotenv.env['X_API_KEY'] ?? '';
String xApiSecretKey = dotenv.env['X_API_SECRET_KEY'] ?? '';

String fcmKey = dotenv.env['FCM_KEY']!;
bool isProduction = dotenv.env['IS_PRODUCTION'] == 'true';
String webBaseUrl = dotenv.env['WEB_BASE_URL']!;
String biometricRecognitionBaseUrl =
    dotenv.env['BIOMETRIC_RECOGNITION_API_BASE_URL']!;
String imageBaseUrl = dotenv.env['IMAGE_BASE_URL']!;
String chatbotBaseUrl = dotenv.env['CHATBOT_BASE_URL'] ?? '';

const REFRESH_TOKEN_KEY = 'refresh_token';
const ACCESS_TOKEN_KEY = 'access_token';
const EXPIRY_TIME_KEY = "expiry_time";
const SUCCESS_MESSAGE = "success";

enum AppEnvironment { development, staging, production }
