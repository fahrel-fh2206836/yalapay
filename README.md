# YalaPay 💳

A modern Flutter B2B application featuring cheque management, invoice processing, and multi-bank payment support.

## 📱 Features

- **Cheque Management**: Complete cheque deposit and status tracking system
- **Invoice Processing**: Invoice creation, management, and payment tracking
- **Payment Modes**: Support for various payment methods including cheques and digital payments
- **Customer Management**: Customer database and relationship management
- **Real-time Updates**: Firebase-powered real-time data synchronization
- **Cross-Platform**: Available on Android and iOS

## 🏗️ Architecture

- **Framework**: Flutter 3.5.3+
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 16.2.1
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Local Database**: SQLite with Floor ORM
- **UI**: Material Design 3 with custom theming

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5.3 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase project setup

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd yalapay
   ```

2. **Navigate to the Flutter project**

   ```bash
   cd yalapay
   ```

3. **Install dependencies**

   ```bash
   flutter pub get
   ```

4. **Generate code (for Floor database)**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── constants/          # App constants and theme colors
├── database/           # SQLite database setup and models
├── model/              # Data models and entities
├── providers/          # Riverpod state management providers
├── repositories/       # Data access layer
├── routes/             # Navigation and routing configuration
├── screens/            # UI screens and pages
├── services/           # Firebase and external services
├── styling/            # Custom themes and styling
├── utils/              # Utility functions and helpers
└── widget/             # Reusable UI components

assets/
├── data/               # JSON data files for banks, payments, etc.
├── fonts/              # Custom DM Sans font family
└── images/             # App icons, logos, and images
```

## 🔧 Configuration

### Firebase Configuration

The app requires Firebase setup for:

- **Firestore**: Real-time database for payments and transactions
- **Authentication**: User management and security
- **Storage**: File and image storage for cheques and documents

### Database Setup

The app uses SQLite with Floor ORM for local data storage on static data to reduce burden on Firebase.

### App Icons and Splash Screen

Icons and splash screens are configured in `pubspec.yaml`:

- App icon: `assets/images/yalapay-with-background.png`
- Splash screen: `assets/images/yalapay_logo_normal_small.png`

## 🎨 Customization

### Theme Colors

The app uses a custom color scheme defined in `lib/constants/constants.dart`:

- Primary colors for Qatar banking theme
- Dark and light mode support
- Custom DM Sans font family

### Adding New Banks

To add new banks, update the `assets/data/banks.json` file with the bank name.

### Payment Modes

Payment modes can be configured in `assets/data/payment-modes.json`.

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)

## 📋 Dependencies

### Core Dependencies

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `firebase_core`: Firebase integration
- `cloud_firestore`: NoSQL database
- `firebase_auth`: Authentication
- `firebase_storage`: File storage
- `sqflite`: Local SQLite database
- `floor`: SQLite ORM

### UI Dependencies

- `curved_navigation_bar`: Custom navigation
- `flutter_native_splash`: Splash screen
- `insta_image_viewer`: Image viewing
- `fluttertoast`: Toast notifications
- `image_picker`: Image selection
