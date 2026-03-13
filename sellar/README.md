# Sellar

A maintainable Flutter application built with best practices and clean architecture.

## Features

- ✨ Clean Architecture with feature-based organization
- 🎨 Modern Material Design 3 theming with dark mode support
- 🧭 Type-safe navigation using GoRouter
- 🔧 Environment configuration with flutter_dotenv
- 📦 State management ready (Flutter BLoC/Provider)
- 🌐 Network layer with Dio
- 💾 Local storage with SharedPreferences and Secure Storage
- 🎯 Comprehensive linting rules
- 📱 iOS and Android support

## Project Structure

```
lib/
├── main.dart                 # Application entry point
└── src/
    ├── config/              # App configuration
    │   ├── app_config.dart     # Environment variables
    │   └── router_config.dart  # Navigation routes
    ├── constants/           # App constants
    ├── features/            # Feature modules
    │   ├── home/
    │   │   └── presentation/   # UI layer
    │   ├── settings/
    │   │   └── presentation/
    │   └── auth/            # Authentication feature
    ├── models/              # Data models
    ├── repositories/        # Data repositories
    ├── services/            # Business logic services
    ├── theme/               # Theme configuration
    │   ├── app_colors.dart
    │   └── app_theme.dart
    ├── widgets/             # Reusable widgets
    └── l10n/                # Internationalization
```

## Getting Started

### Prerequisites

- Flutter SDK (3.6.1 or higher)
- Dart SDK (3.6.1 or higher)
- iOS development: Xcode 15+
- Android development: Android Studio with SDK 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sellar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run the app**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android

   # All available devices
   flutter run
   ```

## Configuration

### Environment Variables

Update `.env` file with your configuration:

```env
APP_NAME=Sellar
API_BASE_URL=https://api.sellar.com
API_TIMEOUT=30000
LOG_LEVEL=debug
```

### Build Variants

```bash
# Development
flutter run --debug

# Staging
flutter run --profile

# Production
flutter run --release
```

## Architecture

### Feature-Based Organization

Each feature follows this structure:
```
feature_name/
├── data/              # Data layer
│   ├── models/       # Data models
│   └── repositories/ # Repository implementations
├── domain/            # Business logic layer
│   ├── entities/     # Domain models
│   └── repositories/ # Repository interfaces
└── presentation/      # UI layer
    ├── screens/      # Screen widgets
    ├── widgets/      # Feature-specific widgets
    └── bloc/         # State management
```

### State Management

This project supports multiple state management approaches:
- **Flutter BLoC**: For complex state management
- **Provider**: For simple state sharing
- **StatefulWidget**: For local component state

## Development

### Code Generation

Run code generators for models and routes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

### iOS

```bash
flutter build ios --release
```

### Android

```bash
flutter build apk --release      # APK
flutter build appbundle --release # App Bundle (recommended)
```

## Key Dependencies

- **go_router**: Type-safe navigation
- **flutter_bloc**: State management
- **dio**: HTTP client
- **flutter_dotenv**: Environment configuration
- **shared_preferences**: Local data storage
- **flutter_secure_storage**: Secure data storage
- **freezed**: Immutable data classes
- **json_serializable**: JSON serialization

## Contributing

1. Create a feature branch
2. Make your changes following the project structure
3. Write tests for new features
4. Run linter and tests
5. Submit a pull request

## Best Practices

- ✅ Follow the feature-based organization
- ✅ Use meaningful names for files and classes
- ✅ Write unit tests for business logic
- ✅ Keep widgets small and focused
- ✅ Use const constructors where possible
- ✅ Document public APIs
- ✅ Handle errors gracefully
- ✅ Use async/await for asynchronous operations

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
