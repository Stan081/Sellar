# Sellar - Architecture Documentation

## Overview

Sellar follows a **feature-based clean architecture** pattern with clear separation of concerns. This document outlines the project structure and architectural decisions.

## Project Structure

```
sellar/
├── lib/
│   ├── main.dart                      # Application entry point
│   └── src/
│       ├── config/                    # Configuration files
│       │   ├── app_config.dart        # Environment and app configuration
│       │   └── router_config.dart     # Navigation configuration (GoRouter)
│       ├── constants/                 # Application constants
│       │   └── app_constants.dart     # API endpoints, timeouts, validation rules
│       ├── features/                  # Feature modules (bounded contexts)
│       │   ├── home/
│       │   │   └── presentation/      # UI layer
│       │   │       └── home_screen.dart
│       │   ├── settings/
│       │   │   └── presentation/
│       │   │       └── settings_screen.dart
│       │   └── auth/                  # Example: Authentication feature
│       │       ├── data/              # Data layer
│       │       │   ├── models/        # DTOs and data models
│       │       │   └── repositories/  # Repository implementations
│       │       ├── domain/            # Business logic layer
│       │       │   ├── entities/      # Domain models
│       │       │   └── repositories/  # Repository interfaces
│       │       └── presentation/      # UI layer
│       │           ├── screens/       # Screen widgets
│       │           ├── widgets/       # Feature-specific widgets
│       │           └── bloc/          # State management (BLoC)
│       ├── models/                    # Shared data models
│       ├── repositories/              # Shared repositories
│       ├── services/                  # Business logic services
│       │   ├── api_service.dart       # HTTP client wrapper (Dio)
│       │   └── storage_service.dart   # Local storage service
│       ├── theme/                     # Theme configuration
│       │   ├── app_colors.dart        # Color palette
│       │   └── app_theme.dart         # Theme definitions
│       ├── widgets/                   # Reusable widgets
│       │   └── common_button.dart     # Example: Common button
│       └── l10n/                      # Internationalization
├── assets/                            # Static assets
│   ├── images/
│   ├── icons/
│   └── translations/
├── test/                              # Unit and widget tests
├── .env                               # Environment variables (gitignored)
├── .env.example                       # Environment template
└── pubspec.yaml                       # Dependencies

```

## Architecture Layers

### 1. Presentation Layer
- **Responsibility**: UI, user interactions, state management
- **Components**: 
  - Screens/Pages
  - Widgets
  - BLoC/Cubit (state management)
- **Dependencies**: Can depend on Domain layer

### 2. Domain Layer (Business Logic)
- **Responsibility**: Core business rules, entities, use cases
- **Components**:
  - Entities (domain models)
  - Repository interfaces
  - Use cases (optional for complex logic)
- **Dependencies**: Independent, no dependencies on other layers

### 3. Data Layer
- **Responsibility**: Data fetching, caching, persistence
- **Components**:
  - Repository implementations
  - Data models (DTOs)
  - Data sources (API, local storage)
- **Dependencies**: Implements Domain layer interfaces

## Design Patterns

### 1. Repository Pattern
Abstracts data sources and provides a clean API for data access.

```dart
// Domain layer
abstract class UserRepository {
  Future<User> getUser(String id);
}

// Data layer
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  
  @override
  Future<User> getUser(String id) async {
    // Implementation
  }
}
```

### 2. BLoC Pattern (Business Logic Component)
Separates business logic from UI using streams and events.

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  
  AuthBloc(this._repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Handle login logic
  }
}
```

### 3. Dependency Injection
Services and repositories are injected rather than created within widgets.

```dart
// Using Provider or GetIt
RepositoryProvider(
  create: (context) => UserRepositoryImpl(
    apiService: context.read<ApiService>(),
  ),
  child: MyApp(),
)
```

## State Management

### Local State
- **StatefulWidget**: For simple, widget-specific state
- **Example**: Form inputs, animations

### Feature State
- **BLoC/Cubit**: For feature-specific state that may be shared across screens
- **Example**: Authentication, user profile

### Global State
- **Provider**: For app-wide state
- **Example**: Theme, locale, user session

## Navigation

Using **GoRouter** for type-safe, declarative navigation:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
)
```

## Data Flow

```
User Action → BLoC/Cubit (Event) → Repository → API/Storage
                                      ↓
UI ← BLoC/Cubit (State Update) ← Repository ← Response
```

## Error Handling

### API Errors
- Handled in `ApiService` with interceptors
- Logged using `Logger` package
- Mapped to domain-specific errors in repositories

### UI Errors
- Displayed using `SnackBar`, `AlertDialog`, or error states
- BLoC emits error states that widgets can react to

## Testing Strategy

### Unit Tests
- Test business logic in BLoCs, repositories, and services
- Mock dependencies using `mocktail`

### Widget Tests
- Test UI components and interactions
- Verify widget behavior with different states

### Integration Tests
- Test complete user flows
- Use `integration_test` package

## File Naming Conventions

- **Screens**: `*_screen.dart` (e.g., `home_screen.dart`)
- **Widgets**: `*_widget.dart` or descriptive names (e.g., `common_button.dart`)
- **Models**: `*_model.dart` (e.g., `user_model.dart`)
- **Repositories**: `*_repository.dart`
- **Services**: `*_service.dart`
- **BLoCs**: `*_bloc.dart`, `*_event.dart`, `*_state.dart`

## Code Style Guidelines

1. **Use const constructors** wherever possible for performance
2. **Follow Effective Dart** naming conventions
3. **Document public APIs** with doc comments
4. **Keep widgets focused** - single responsibility
5. **Prefer composition** over inheritance
6. **Use meaningful names** for variables, functions, and classes
7. **Handle errors gracefully** - never ignore errors
8. **Write tests** for critical business logic

## Environment Configuration

Environment variables are managed using `flutter_dotenv`:

```dart
// .env file
APP_NAME=Sellar
API_BASE_URL=https://api.sellar.com
API_TIMEOUT=30000
```

Access in code:
```dart
final apiUrl = AppConfig.apiBaseUrl;
```

## Asset Management

Assets are organized by type:
- `assets/images/` - PNG, JPG images
- `assets/icons/` - SVG icons
- `assets/translations/` - i18n JSON files

Reference in pubspec.yaml:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

## Future Enhancements

- [ ] Add comprehensive error handling with custom exceptions
- [ ] Implement offline-first with local database (Hive/Drift)
- [ ] Add analytics and crash reporting (Firebase)
- [ ] Implement CI/CD pipeline
- [ ] Add performance monitoring
- [ ] Implement feature flags
- [ ] Add end-to-end tests
- [ ] Implement background tasks
- [ ] Add biometric authentication
- [ ] Implement deep linking

## Resources

- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
