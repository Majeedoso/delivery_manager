# Auth Feature Documentation

## Overview

The Auth feature is responsible for handling all authentication-related functionality in the delivery operator app. It follows Clean Architecture principles, separating concerns into three layers: **Presentation**, **Domain**, and **Data**.

## Architecture

```
features/auth/
├── presentation/          # UI Layer
│   ├── controller/       # BLoC state management
│   ├── helpers/          # Navigation helpers
│   └── screens/         # UI screens
├── domain/              # Business Logic Layer
│   ├── entities/        # Business entities
│   ├── repository/      # Repository interfaces
│   └── usecases/       # Business use cases
└── data/               # Data Layer
    ├── datasource/     # Data sources (remote & local)
    ├── models/         # Data models
    └── repository/     # Repository implementations
```

## Presentation Layer

### Controllers (BLoC Pattern)

#### AuthBloc
**Location:** `presentation/controller/auth_bloc.dart`

**Purpose:** Manages authentication state and handles all authentication operations.

**Events:**
- `LoginEvent`: User login with email and password
- `RegisterEvent`: New user registration
- `LogoutEvent`: User logout
- `CheckAuthStatusEvent`: Check if user is authenticated
- `GoogleSignInEvent`: Sign in with Google
- `GoogleSignUpEvent`: Sign up with Google
- `GoogleSignOutEvent`: Sign out from Google

**State:** `AuthState`
- `requestState`: Current request state (loading, loaded, error)
- `user`: Authenticated user object
- `message`: Success or error message
- `isAuthenticated`: Authentication flag

**Key Operations:**
1. **Login**: Validates credentials, saves token, sends FCM token to server
2. **Register**: Creates new account, saves token
3. **Logout**: Clears local token (always succeeds even if server fails)
4. **Check Auth Status**: Validates token and fetches current user
5. **Google Sign-In/Up**: Handles OAuth flow via Firebase

#### SplashBloc
**Location:** `presentation/controller/splash_bloc.dart`

**Purpose:** Orchestrates app initialization sequence on splash screen.

**Events:**
- `InitializeAppEvent`: Start initialization
- `CheckInternetConnectionEvent`: Check internet connectivity
- `RequestNotificationPermissionEvent`: Request notification permission
- `RetryInitializationEvent`: Retry failed initialization

**State:** `SplashState`
- `requestState`: Current request state
- `currentStep`: Current initialization step (SplashStep enum)
- `statusMessage`: Localized status message key
- `hasInternetConnection`: Internet connectivity status
- `hasNotificationPermission`: Notification permission status
- `errorMessage`: Error message if initialization fails

**Initialization Sequence:**
1. Check internet connection (required)
2. Check notification permission (required)
3. Initialize notification service (with timeout)
4. Check authentication status (via AuthBloc)

### Screens

#### SplashScreen
**Location:** `presentation/screens/splash_screen.dart`

**Purpose:** First screen shown on app launch. Handles initialization and navigation.

**Features:**
- Displays app logo and status messages
- Shows loading indicators during initialization
- Handles error states with retry options
- Listens to both SplashBloc and AuthBloc for navigation

**Navigation Logic:**
- Uses `AuthNavigationHelper.navigateBasedOnUserStatus()` to determine destination
- Authenticated users → MainScreen or AccountStatusScreen
- Unauthenticated users → LoginScreen

#### LoginScreen
**Location:** `presentation/screens/login_screen.dart`

**Purpose:** User login interface.

**Features:**
- Email and password form
- "Remember me" functionality (saves credentials locally)
- Google Sign-In button
- Links to sign-up and forgot password screens
- Language selection in app bar

**Validation:**
- Email must contain '@'
- Password minimum 6 characters

#### SignupScreen
**Location:** `presentation/screens/signup_screen.dart`

**Purpose:** New user registration interface.

**Features:**
- Registration form (name, email, phone, password, confirm password)
- Google Sign-Up button
- Link to login screen
- Language selection in app bar

**Password Requirements:**
- Minimum 8 characters
- Must contain: uppercase, lowercase, number, and symbol

#### AccountStatusScreen
**Location:** `presentation/screens/account_status_screen.dart`

**Purpose:** Displays account approval status for business users.

**Status Types:**
- `pending_approval`: Waiting for manager approval
- `suspended`: Account suspended
- `rejected`: Account rejected (shows rejection reason)

**Features:**
- Status-specific icons and messages
- "Check Status" button for pending accounts
- Logout option

#### ForgotPasswordScreen
**Location:** `presentation/screens/forgot_password_screen.dart`

**Purpose:** Password reset request interface.

**Features:**
- Email input for password reset
- Countdown timer to prevent spam
- Navigates to ResetPasswordScreen after email sent

#### ResetPasswordScreen
**Location:** `presentation/screens/reset_password_screen.dart`

**Purpose:** Password reset with OTP verification.

**Features:**
- OTP input with auto-detection (SMS and clipboard)
- Password and confirm password fields
- Resend OTP with countdown
- Auto-verification when OTP detected

### Helpers

#### AuthNavigationHelper
**Location:** `presentation/helpers/auth_navigation_helper.dart`

**Purpose:** Centralizes navigation logic for authentication flows.

**Methods:**
- `getRouteForUser(User?)`: Returns appropriate route based on user status
- `navigateBasedOnUserStatus(BuildContext, User?)`: Navigates to appropriate screen

**Navigation Rules:**
1. `null` user → LoginScreen
2. Business users (operator, restaurant, delivery, manager):
   - Pending/Suspended/Rejected → AccountStatusScreen
   - Approved → MainScreen
3. Customer users → MainScreen (no approval needed)

## Domain Layer

### Entities

#### User
**Location:** `domain/entities/user.dart`

**Properties:**
- `id`: User ID
- `name`: Full name
- `email`: Email address
- `phone`: Phone number
- `role`: UserRole enum (operator, restaurant, delivery, manager, customer)
- `token`: Authentication token (optional, for backward compatibility)
- `googleId`: Google account ID (if signed in with Google)
- `status`: Account status (active, pending_approval, suspended, rejected)
- `approvedBy`: Manager ID who approved (if applicable)
- `approvedAt`: Approval timestamp
- `rejectionReason`: Reason for rejection (if applicable)

**Computed Properties:**
- `isApproved`: Check if account is active
- `isPendingApproval`: Check if waiting for approval
- `isSuspended`: Check if suspended
- `isRejected`: Check if rejected
- `canPerformBusinessOperations`: Check if can perform business operations

#### AuthResponse
**Location:** `domain/entities/auth_response.dart`

**Properties:**
- `user`: Authenticated user object
- `token`: Authentication token
- `message`: Success message

### Use Cases

All use cases follow the same pattern:
- Extend `UseCase<ReturnType, Parameters>`
- Return `Either<Failure, ReturnType>`
- Handle errors via Failure classes

**Authentication Use Cases:**

- **`LoginUseCase`**: Authenticates user with email and password. Sends credentials to backend API, receives authentication token and user data. Repository automatically saves token and user data locally. Parameters: `LoginParameters` (email, password).

- **`RegisterUseCase`**: Registers a new user with email and password. Creates new account, receives authentication token upon success. Repository automatically saves token and user data locally. Parameters: `RegisterParameters` (name, email, password, role, phone).

- **`LogoutUseCase`**: Logs out the current user. Notifies backend server (non-blocking), clears local user data and authentication token. Always succeeds locally even if server request fails.

- **`GetCurrentUserUseCase`**: Retrieves the currently authenticated user. First tries local storage, then attempts to fetch fresh user data from server. Returns null if no user is authenticated. Falls back to local data if server fetch fails.

- **`CheckAuthStatusUseCase`**: Checks if user is currently authenticated by retrieving saved token and validating it with backend server. Returns true if valid token exists and is confirmed by server, false otherwise. Used during app startup.

**Google Authentication Use Cases:**

- **`GoogleSignInUseCase`**: Signs in existing users with Google. Initiates Google Sign-In via Firebase, authenticates with Firebase, sends user data to backend API. Repository automatically saves token and user data locally. Returns User entity with token.

- **`GoogleSignUpUseCase`**: Signs up new users with Google. Similar flow to GoogleSignInUseCase. Backend determines whether to create new account or authenticate existing one based on Google ID.

- **`GoogleSignOutUseCase`**: Signs out from Google authentication. Signs out from Firebase Authentication and Google Sign-In service, clears local user data and token.

**Token Management Use Cases:**

- **`SaveTokenUseCase`**: Saves authentication token to secure storage (Flutter Secure Storage) for persistent authentication across app sessions. Parameters: `SaveTokenParameters` (token).

- **`GetTokenUseCase`**: Retrieves saved authentication token from secure storage. Returns null if no token is saved. Used to get token for authenticated API requests.

- **`ClearTokenUseCase`**: Removes saved authentication token from secure storage. Used during logout or when authentication needs to be cleared.

- **`ValidateTokenUseCase`**: Validates authentication token with backend server. Sends token to backend API to verify if it's still valid. Returns true if valid, false if invalid or expired. Used during app startup.

**Credential Storage Use Cases:**

- **`SaveCredentialsUseCase`**: Saves user credentials (email/password) to secure storage when "Remember Me" is enabled. If rememberMe is false, clears any existing saved credentials. Parameters: `SaveCredentialsParameters` (email, password, rememberMe).

- **`LoadCredentialsUseCase`**: Retrieves previously saved credentials from secure storage. Returns map with 'email', 'password', and 'rememberMe' keys. Used to pre-fill login form.

- **`ClearCredentialsUseCase`**: Removes saved credentials from secure storage. Used when user disables "Remember Me" or explicitly wants to clear credentials.

## Data Layer

### Data Sources

#### Remote Data Sources

**Abstract Interfaces:**
- `BaseAuthRemoteDataSource`: Defines contract for authentication API operations (register, login, logout, FCM token updates)
- `BaseGoogleAuthRemoteDataSource`: Defines contract for Google Sign-In/Sign-Up operations
- `BaseTokenRemoteDataSource`: Defines contract for token validation with backend API

**Implementations:**

- **`AuthRemoteDataSource`**: Makes HTTP requests to backend authentication API using Dio. Handles:
  - User registration via POST to register endpoint
  - User login via POST to login endpoint
  - User logout via POST to logout endpoint (with token in Authorization header)
  - FCM token updates via POST to update FCM token endpoint
  - Error conversion from DioException to custom exceptions (ServerException, NetworkException)
  - Timeout handling for network requests

- **`GoogleAuthRemoteDataSource`**: Handles Google authentication flow:
  - Coordinates between Firebase Authentication, Google Sign-In SDK, and backend API
  - Disconnects previous Google account before new sign-in (forces account picker)
  - Authenticates with Firebase using Google credentials (15s timeout for Firebase auth)
  - Sends user data to backend API for authentication/registration (30s send timeout, 45s receive timeout, 60s overall timeout)
  - Returns User entity with token
  - Handles timeout and error conversion

- **`TokenRemoteDataSource`**: Validates authentication tokens:
  - Makes GET request to user endpoint with token in Authorization header
  - Uses shorter timeouts (5s send/receive, 8s overall) for faster validation during splash screen
  - Returns true if token is valid (status 200), false if invalid (status 401)
  - Handles timeout and connection errors

#### Local Data Sources

**Abstract Interfaces:**
- `BaseAuthLocalDataSource`: Defines contract for local user data persistence
- `BaseTokenLocalDataSource`: Defines contract for secure token storage
- `BaseSecureStorageLocalDataSource`: Defines contract for secure credential storage

**Implementations:**

- **`AuthLocalDataSource`**: Uses SharedPreferences to persist user data and tokens locally:
  - Saves user data as JSON string
  - Saves authentication token as plain string
  - Retrieves user data and token from SharedPreferences
  - Clears user data and token on logout
  - Throws LocalDatabaseException if storage operations fail

- **`TokenLocalDataSource`**: Uses Flutter Secure Storage for encrypted token storage:
  - Saves token to secure storage (encrypted on Android, iOS Keychain on iOS)
  - Retrieves token from secure storage
  - Checks if token exists
  - Clears token from secure storage
  - Platform-specific options: EncryptedSharedPreferences on Android, Keychain on iOS

- **`SecureStorageLocalDataSource`**: Uses Flutter Secure Storage for encrypted credential storage:
  - Saves email, password, and rememberMe flag to secure storage
  - Retrieves saved credentials
  - Checks if credentials are saved
  - Clears credentials from secure storage
  - Platform-specific encryption (same as TokenLocalDataSource)

### Models

Models are data transfer objects (DTOs) that:
- Extend domain entities
- Handle JSON serialization/deserialization
- Convert between domain entities and JSON
- Parse role strings to UserRole enum

**Key Models:**

- **`UserModel`**: Extends `User` entity
  - Provides `fromJson()` factory constructor to parse API responses
  - Provides `toJson()` method for JSON serialization
  - Handles type conversion (e.g., ID can be int or string)
  - Parses role string to `UserRole` enum (customer, restaurant, delivery, manager, operator)
  - Handles nullable fields (token, googleId, status, approvedBy, approvedAt, rejectionReason)
  - Used for data transfer between API and domain layer

- **`AuthResponseModel`**: Extends `AuthResponse` entity
  - Provides `fromJson()` factory constructor to parse authentication API responses
  - Provides `toJson()` method for JSON serialization
  - Handles API response structure:
    ```json
    {
      "data": {
        "user": { ... },
        "token": "..."
      },
      "message": "..."
    }
    ```
  - Converts nested `UserModel` from JSON
  - Used for login and registration responses

### Repository Interfaces

**Abstract Repositories (Domain Layer):**

- **`BaseAuthRepository`**: Defines contract for all authentication operations:
  - Register user with email/password
  - Login user with email/password
  - Logout user
  - Get current authenticated user
  - Google Sign-In, Sign-Up, and Sign-Out
  - All methods return `Either<Failure, ReturnType>`

- **`BaseTokenRepository`**: Defines contract for authentication token management:
  - Save token securely
  - Get saved token
  - Clear token
  - Check if token exists
  - Validate token with server
  - All methods return `Either<Failure, ReturnType>`

- **`BaseSecureStorageRepository`**: Defines contract for secure credential storage:
  - Save credentials (email/password) for "Remember Me"
  - Load saved credentials
  - Clear saved credentials
  - Check if credentials are saved
  - All methods return `Either<Failure, ReturnType>`

### Repository Implementations

Repository implementations bridge the gap between domain and data layers, coordinating between remote and local data sources:

- **`AuthRepository`**: Implements `BaseAuthRepository`
  - Coordinates between `AuthRemoteDataSource`, `AuthLocalDataSource`, `GoogleAuthRemoteDataSource`, and `TokenRepository`
  - Handles error conversion from exceptions to failures
  - Ensures local data is synchronized with remote operations
  - Saves user data and token locally upon successful authentication
  - Fetches fresh user data from server when getting current user (with fallback to local data)
  - Logout sends non-blocking request to server and always clears local data

- **`TokenRepository`**: Implements `BaseTokenRepository`
  - Coordinates between `TokenLocalDataSource` (secure storage) and `TokenRemoteDataSource` (validation)
  - Handles error conversion from exceptions to failures
  - Provides unified interface for token operations
  - Saves tokens securely using Flutter Secure Storage
  - Validates tokens with backend API

- **`SecureStorageRepository`**: Implements `BaseSecureStorageRepository`
  - Uses `SecureStorageLocalDataSource` for credential storage
  - Handles error conversion from exceptions to failures
  - Manages user credentials (email/password) for "Remember Me" functionality
  - Provides unified interface for credential operations

## Authentication Flow

### Login Flow
1. User enters email and password
2. `LoginScreen` dispatches `LoginEvent` to `AuthBloc`
3. `AuthBloc` calls `LoginUseCase`
4. Use case calls `AuthRepository.login()`
5. Repository makes API call via `AuthRemoteDataSource`
6. Response is converted to `AuthResponse` entity
7. Token is saved via `SaveTokenUseCase`
8. FCM token is sent to server
9. `AuthBloc` emits success state with user data
10. `LoginScreen` navigates using `AuthNavigationHelper`

### Google Sign-In Flow
1. User taps "Sign in with Google"
2. `LoginScreen` dispatches `GoogleSignInEvent`
3. `AuthBloc` calls `GoogleSignInUseCase`
4. Use case:
   - Disconnects previous Google account
   - Shows Google account picker
   - Authenticates with Firebase
   - Sends credentials to backend
   - Returns user entity
5. FCM token is sent to server
6. `AuthBloc` emits success state
7. Navigation proceeds as in Login Flow

### App Initialization Flow (Splash Screen)
1. App starts, `SplashScreen` loads
2. `SplashBloc` receives `InitializeAppEvent`
3. **Step 1**: Check internet connection (required)
   - If no internet: Show error, allow retry
4. **Step 2**: Check notification permission (required)
   - If denied: Show permission request button
5. **Step 3**: Initialize notification service (with 10s timeout)
   - Non-critical, app continues even if fails
6. **Step 4**: Check authentication status
   - `SplashBloc` dispatches `CheckAuthStatusEvent` to `AuthBloc`
   - `AuthBloc` validates token and fetches user
   - `SplashScreen` listens to `AuthBloc` state changes
   - Navigation based on authentication status

### Logout Flow
1. User triggers logout
2. `LogoutEvent` dispatched to `AuthBloc`
3. `AuthBloc` calls `LogoutUseCase` (5s timeout)
4. Even if server logout fails, local token is cleared
5. `AuthBloc` emits unauthenticated state
6. App navigates to `LoginScreen`

## Error Handling

### Error Types
- `ServerException`: Backend API errors
- `NetworkException`: Network connectivity issues
- `LocalDatabaseException`: Local storage errors
- `DioException`: HTTP request errors
- `TimeoutException`: Request timeout errors

### Error Flow
1. Error occurs in data layer
2. Converted to `Failure` object
3. Propagated through use case
4. Returned as `Either<Failure, Success>`
5. BLoC handles failure and emits error state
6. UI displays error message to user

## Security Considerations

### Token Management
- Tokens stored securely using `flutter_secure_storage`
- Tokens validated on app startup
- Tokens cleared on logout (even if server fails)

### Google Authentication
- OAuth 2.0 flow with Firebase
- Account picker always shown (no cached account)
- Previous account disconnected before new sign-in
- Timeouts configured for reliability

### Password Storage
- "Remember me" stores credentials locally (secure storage)
- Only saved if user explicitly checks "Remember me"
- Credentials loaded on login screen initialization

## Testing Considerations

### Unit Tests
- Test use cases with mock repositories
- Test BLoC event handlers
- Test entity computed properties

### Integration Tests
- Test authentication flows end-to-end
- Test navigation logic
- Test error handling

## Future Enhancements

1. **Biometric Authentication**: Add fingerprint/face recognition
2. **Two-Factor Authentication**: SMS or email OTP
3. **Social Login**: Facebook, Apple Sign-In
4. **Session Management**: Auto-logout after inactivity
5. **Token Refresh**: Automatic token refresh before expiry

## Dependencies

### External Packages
- `flutter_bloc`: State management
- `equatable`: Value equality
- `google_sign_in`: Google OAuth
- `firebase_auth`: Firebase authentication
- `flutter_secure_storage`: Secure token storage
- `permission_handler`: Permission management
- `internet_connection_checker`: Connectivity checking
- `dio`: HTTP client

### Internal Dependencies
- `core/utils/enums`: Enumerations
- `core/usecase/base_usecase`: Base use case class
- `core/services/notification_service`: Notification handling
- `core/services/connectivity_service`: Connectivity checking
- `core/services/permission_service`: Permission handling

## Summary

The Auth feature is a well-structured, maintainable implementation following Clean Architecture principles. It separates concerns clearly, making it easy to test, maintain, and extend. The use of BLoC pattern ensures predictable state management, while the use case pattern encapsulates business logic independently of the UI and data layers.

