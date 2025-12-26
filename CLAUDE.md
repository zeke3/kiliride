# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**kiliride** is a Flutter mobile application for a ride-sharing/transportation service with multi-role support (clients, providers/drivers, and sales agents). The app uses a Django REST backend for authentication and data management.

## Development Commands

### Setup & Dependencies
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for production
flutter build apk --release          # Android
flutter build ipa --release          # iOS
flutter build appbundle --release    # Android App Bundle
```

### Testing & Analysis
```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Environment Setup
- Requires `.env` file in root with configuration variables:
  - `BASE_URL` - Backend API URL
  - `MAP_API_KEY` - Google Maps API key
  - `X_API_KEY` and `X_API_SECRET_KEY` - API authentication
  - `FCM_KEY` - Firebase Cloud Messaging key
  - `IS_PRODUCTION` - Production flag (true/false)
  - `WEB_BASE_URL` - Web application URL
  - `BIOMETRIC_RECOGNITION_API_BASE_URL` - Biometric service URL
  - `IMAGE_BASE_URL` - Image service URL
  - `CHATBOT_BASE_URL` - Chatbot service URL

## Architecture Overview

### Authentication & Token Management

The app implements a **JWT-based authentication system** with automatic token refresh:

1. **AuthService** (`lib/services/auth.service.dart`): Singleton handling all authentication operations (login, register, OTP, password reset)
2. **RefreshTokenService** (`lib/services/refresh_token.service.dart`): Automatic token refresh every 5 minutes, handles 401 errors by clearing tokens and triggering logout
3. **TokenInterceptor** (`lib/services/token_interceptor.service.dart`): Dio interceptor that adds Bearer token to requests
4. **Wrapper** (`lib/wrapper.dart`): Entry point widget that checks token validity on app launch and routes users based on authentication state

**Authentication Flow:**
- On app start → `Wrapper` checks tokens via `RefreshTokenService.init()`
- If valid → fetch user profile → navigate to role-specific screen
- If invalid/expired → show `GetStartedScreen`
- On 401 error → `RefreshTokenService` calls `onAuthenticationFailure` callback → clear tokens → navigate to login

### State Management

Uses **Riverpod** with ChangeNotifier providers:

- **userInfoProvider**: Manages current user state (`lib/providers/user.provider.dart`)
- **appDataProvider**: Handles app-wide data initialization and caching (`lib/providers/app_data.provider.dart`)

All providers defined in `lib/providers/providers.dart`.

### Navigation & Routing

The app uses **named routes** with custom `AppRouter` (`lib/routes/router.dart`):

- Authentication routes: `/login`, `/signup`, `/getstarted`, `/otp-verification`, etc.
- Role-based navigation screens:
  - `/client-navigation` - For regular users/riders
  - `/provider-navigation` - For drivers/service providers
  - `/sales-navigation` - For sales agents

User type is stored in `UserModel.userType` and determines which navigation screen to display.

### Multi-Language Support

Implements custom localization using **GetX translations**:

- Translation files: `lib/translations/{en,es,fr,pt,sw}.dart`
- LocaleService: `lib/services/locale.service.dart`
- LanguageService: `lib/services/language_service.dart` (stores language preference)

### Firebase Integration

- **Firestore**: Used for app configuration (version control, feature flags)
- **Firebase Storage**: File/image storage (bucket: `gs://daykiliride-768aa.firebasestorage.app`)
- **Firebase Messaging**: Push notifications via FCM

Initialization in `lib/main.dart` via `AppInitializer.initializeApp()`.

### Notification System

Custom notification handler (`lib/controllers/notification_handler.dart`) built on **awesome_notifications**:
- Handles foreground/background/terminated notification states
- Updates app badge count based on unread notifications
- Manages notification permissions and opt-in flow

### Important Patterns

1. **Secure Storage**: All tokens stored in `flutter_secure_storage` with keys defined in `lib/shared/constants.dart`:
   - `ACCESS_TOKEN_KEY` = "access_token"
   - `REFRESH_TOKEN_KEY` = "refresh_token"
   - `EXPIRY_TIME_KEY` = "expiry_time"

2. **Error Handling**: DioException handling with specific type checking (connection timeout, bad response, etc.) - see `AuthService` for reference pattern

3. **Guest Mode**: Guest user functionality via `lib/services/guest_mode_service.dart`

4. **API Response Format**: Backend returns standardized structure:
   ```json
   {
     "success": bool,
     "status": string,
     "message": string,
     "data": object,
     "status_code": int (on error)
   }
   ```

### Key Services

- **AuthService**: All authentication endpoints (singleton pattern)
- **RefreshTokenService**: Token lifecycle management (singleton)
- **DBService/db_service.dart**: Firestore database access
- **LocationService**: Geolocator integration
- **ConnectivityService**: Network status monitoring
- **ImageService**: Image upload/processing
- **ChatbotService**: Chatbot API integration

### Testing Notes

- Test OTP functionality uses dummy credentials for Play Console testing:
  - Phone: `+255678778998`
  - OTP: `123456`

### Version Control & Updates

App checks Firestore `appData/versionControl` document on launch for:
- `latestVersion`: Current app version
- `forceUpdate`: Whether to require update
- `disableDialog`: Hide update prompt
- `playStoreUrl`/`appStoreUrl`: Store links

Implemented in `_SasMobileAppState.checkForUpdate()` in `lib/main.dart`.
