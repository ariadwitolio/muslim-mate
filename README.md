# Muslim Mate - Flutter App

A modern Islamic companion mobile application built with Flutter, featuring prayer times, Islamic content, and community features.

## Project Structure

```
muslim_mate/
├── lib/
│   ├── constants/          # App-wide constants and theming
│   │   ├── app_colors.dart       # Color palette
│   │   ├── app_theme.dart        # Material 3 theme configuration
│   │   └── index.dart            # Barrel export file
│   │
│   ├── models/             # Data models
│   │   ├── user.dart             # User model with JSON serialization
│   │   └── index.dart            # Barrel export file
│   │
│   ├── services/           # Business logic and API calls
│   │   ├── api_service.dart      # HTTP client for API requests
│   │   └── index.dart            # Barrel export file
│   │
│   ├── screens/            # UI screens
│   │   ├── home_screen.dart      # Home screen starting point
│   │   └── index.dart            # Barrel export file
│   │
│   ├── widgets/            # Reusable UI components
│   │   ├── custom_app_bar.dart   # Custom app bar widget
│   │   └── index.dart            # Barrel export file
│   │
│   ├── utils/              # Utility functions and helpers
│   │   ├── logger.dart           # Logging utility
│   │   └── index.dart            # Barrel export file
│   │
│   └── main.dart           # Application entry point
│
├── test/                   # Unit and widget tests
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── pubspec.yaml            # Flutter dependencies and project config
└── README.md              # This file
```

## Dependencies

### Production Dependencies
- **flutter**: Flutter SDK
- **cupertino_icons**: iOS-style icons
- **provider**: ^6.1.5+1 - State management
- **http**: ^1.6.0 - HTTP client for API calls
- **intl**: ^0.19.0 - Internationalization support
- **google_fonts**: ^6.3.3 - Custom Google Fonts

### Development Dependencies
- **flutter_test**: Flutter testing framework
- **flutter_lints**: Linting rules

## Getting Started

### Prerequisites
- Flutter SDK (3.11.5+)
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Navigate to project directory:**
   ```bash
   cd /Users/aria/Documents/muslim-mate/muslim_mate
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Architecture

This project follows clean architecture principles:

### Constants Layer (`constants/`)
- Centralized color scheme and theming
- Material 3 design implementation
- App-wide styling consistency

### Models Layer (`models/`)
- Data classes with JSON serialization
- Business entity definitions
- Type safety through Dart classes

### Services Layer (`services/`)
- API integration and HTTP requests
- Business logic separation
- Network error handling

### Screens Layer (`screens/`)
- Full-page UI components
- Navigation entry points
- Screen-level state management

### Widgets Layer (`widgets/`)
- Reusable UI components
- Custom widgets for common patterns
- Widget composition

### Utils Layer (`utils/`)
- Helper functions
- Logging utilities
- Common algorithms

## Theming

The app uses Material 3 with custom colors defined in `lib/constants/app_colors.dart`:

- **Primary**: Islamic green (#2C5F2D)
- **Secondary**: Islamic gold (#F0D23D)
- **Neutral**: Professional greys and blacks
- **Status**: Success, error, warning, info colors

### Light & Dark Themes
Both light and dark themes are implemented with automatic system detection.

## Code Style

- **Naming**: camelCase for variables, snake_case for files
- **Organization**: Feature-based folder structure
- **Imports**: Organized and using barrel exports
- **Documentation**: Comments for complex logic
- **Formatting**: Dart formatting standards

## Logging

Use the `Logger` utility for application logging:

```dart
import 'package:muslim_mate/utils/logger.dart';

Logger.debug('Debug message');
Logger.info('Information message');
Logger.warning('Warning message');
Logger.error('Error message', error, stackTrace);
```

## API Integration

The `ApiService` provides methods for HTTP requests:

```dart
final apiService = ApiService(baseUrl: 'https://api.example.com');

// GET request
final data = await apiService.get('/endpoint');

// POST request
final response = await apiService.post('/endpoint', body: {'key': 'value'});

// PUT request
await apiService.put('/endpoint', body: {'key': 'value'});

// DELETE request
await apiService.delete('/endpoint');
```

## State Management

Provider is used for state management. Example structure:

```dart
class UserProvider extends ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

## Next Steps

1. **Connect Figma Designs**: Convert designs from Figma file to Flutter widgets
2. **Add Screens**: Create additional screens for Islamic features
3. **Implement State Management**: Set up Provider for app-wide state
4. **API Integration**: Connect to backend API
5. **Testing**: Write unit and widget tests
6. **Localization**: Add multi-language support using intl

## Testing

Run tests with:
```bash
flutter test
```

## Build & Release

### Android
```bash
flutter build apk
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## Troubleshooting

### Pub Get Issues
```bash
flutter pub cache clean
flutter pub get
```

### Build Issues
```bash
flutter clean
flutter pub get
flutter run
```

### IDE Issues
- Restart IDE
- Re-open project
- Run `flutter analyze`

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Material 3 Design](https://m3.material.io/)
- [Dart Language](https://dart.dev/)
- [Provider Package](https://pub.dev/packages/provider)

## Figma Design System

This project integrates with Figma design system:
- **File**: Muslim-Mate - Muslim App 2
- **Components**: Icon Button, Labacash Filled, System Activities
- **Variables**: Translation strings, Language Manager
- **Libraries**: Labamu Component, Catalog

## Author

Muslim Mate Team

## License

© 2026 Muslim Mate. All rights reserved.
