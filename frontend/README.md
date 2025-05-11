# Easy Scooter Shared Scooter Application

Easy Scooter is a shared scooter application developed with Flutter, providing scooter rental, payment, and user management features. The application supports multiple platforms including Android, iOS, Windows, and Web.

## Features

- 🛴 Scooter Management
  - Real-time updated available scooter list
  - Scooter location tracking using Flutter Map
  - Scooter status monitoring (available, in-use, maintenance)
  - Scooter rating and review system

- 💳 Payment System
  - Support for multiple payment cards
  - Secure payment card management
  - Default card settings
  - Card verification and confirmation

- 👤 User Management
  - User registration and login
  - Personal information management
  - Avatar upload and compression
  - Local data synchronization using SharedPreferences

- 📝 Rental Management
  - Create and manage rental records
  - View rental history
  - Track rental status
  - Fee calculation and payment processing

- 💬 Smart Assistant
  - Real-time chat interface
  - Problem solving and support
  - User guides and tips
  - Message history management

- 📱 Additional Features
  - QR code scanning for scooter unlocking
  - Location-based services
  - Device feature permission handling
  - Multi-language support (Chinese, English)

## Requirements

- Flutter SDK (>=2.19.4)
- Dart SDK (>=2.19.4)
- Android Studio / VS Code
- Git
- Windows SDK (for Windows build)
- Web browser (for Web build)

## Installation Steps

1. Clone the project
```bash
git clone git@github.com:XJCO2913-Group-1/XJCO2913-Group-1.git
cd easy_scooter_fe
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the project
```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Windows build
flutter build windows

# Web build
flutter build web
```

## Project Structure

```
├── lib/                    # Main source code directory
│   ├── components/        # Reusable UI components
│   ├── models/           # Data models and entities
│   ├── pages/            # Application pages
│   ├── providers/        # State management using Provider
│   ├── services/         # API and business logic services
│   ├── utils/            # Utility functions and helper methods
│   └── main.dart         # Application entry file
│
├── test/                  # Test directory
│   ├── unit/             # Unit tests
│   ├── component/        # Component tests
│   ├── system/           # System tests
│   └── mocks/            # Mock objects for testing
│
├── assets/               # Resource files directory
│   ├── images/          # Image resources
│   └── fonts/           # Font files
│
├── android/              # Android platform specific code
├── ios/                  # iOS platform specific code
├── web/                  # Web platform specific code
├── windows/              # Windows platform specific code
│
├── pubspec.yaml          # Project configuration and dependency management
└── README.md            # Project documentation
```

## Dependencies

Main dependencies include:
- `flutter_map` and `latlong2` for maps and location
- `provider` for state management
- `dio` for API communication
- `shared_preferences` for local storage
- `mobile_scanner` for QR code scanning
- `permission_handler` for device permissions
- `image_picker` and `flutter_image_compress` for image processing
- `carousel_slider` for UI components

## Testing

The project includes a comprehensive test suite, divided into three main categories:

1. Unit Tests (`test/unit/`)
   - Test individual classes and methods
   - Verify business logic correctness
   - Mock dependencies for isolated testing
   ```bash
   # Run all unit tests
   flutter test test/unit/
   
   # Run specific test files
   flutter test test/unit/mock_payment_card_provider.dart
   flutter test test/unit/mock_user_provider.dart
   flutter test test/unit/mock_scooters_provider.dart
   ```

2. Component Tests (`test/component/`)
   - Test UI component rendering and interaction
   - Verify component state management
   - Test user interface responses
   ```bash
   # Run all component tests
   flutter test test/component/
   ```

3. System Tests (`test/system/`)
   - Test complete functional flows
   - Verify system integration
   - End-to-end testing
   ```bash
   # Run all system tests
   flutter test test/system/
   ```

Test coverage report:
```bash
# Generate test coverage report
flutter test --coverage
```

## Platform-specific Builds

### Windows
```bash
flutter build windows
```

### Web
```bash
flutter build web
```

### Android
```bash
flutter build apk
```

## Verifying Project Setup

1. Check dependencies
```bash
flutter pub get
flutter doctor
```

2. Run test suite
```bash
# Run all tests
flutter test

# Check test coverage
flutter test --coverage
```

3. Launch application
```bash
flutter run
```

Success indicators:
- All tests pass
- Application launches successfully
- Login interface is visible
- Scooter list loads normally
- Maps and location services work properly
- QR code scanning functions correctly

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details