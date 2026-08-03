# Release Setup (User + Staff)

This project now supports two app variants:

- `user` -> patient app (`lib/main.dart`)
- `staff` -> staff/admin app (`lib/main_staff.dart`)

## 1) Android setup

### Package IDs

- User: `com.mobadra.user`
- Staff: `com.mobadra.staff`

### Generate test APKs

```bash
flutter build apk --flavor user --target lib/main.dart --release
flutter build apk --flavor staff --target lib/main_staff.dart --release
```

APKs will be under:

- `build/app/outputs/flutter-apk/app-user-release.apk`
- `build/app/outputs/flutter-apk/app-staff-release.apk`

### Generate Play Store bundles (AAB)

```bash
flutter build appbundle --flavor user --target lib/main.dart --release
flutter build appbundle --flavor staff --target lib/main_staff.dart --release
```

Bundles will be under:

- `build/app/outputs/bundle/userRelease/app-user-release.aab`
- `build/app/outputs/bundle/staffRelease/app-staff-release.aab`

### Release signing (required for stores)

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill real values:
   - `storeFile` -> path to your `.jks` keystore
   - `storePassword`
   - `keyAlias`
   - `keyPassword`

Do **not** commit `android/key.properties` or keystore files.

## 2) iOS setup (on Mac)

iOS is parameterized with:

- `APP_DISPLAY_NAME`
- `APP_BUNDLE_ID`

Default in xcconfig is the user app.

### Build user app

Use Xcode Runner target with:

- Bundle ID: `com.mobadra.user`
- Display name: `Creative Mobadra`
- Entry point: `lib/main.dart`

### Build staff app

In Xcode build settings (or duplicate target/scheme), set:

- `APP_BUNDLE_ID = com.mobadra.staff`
- `APP_DISPLAY_NAME = Mobadra Staff`
- Entry point: `lib/main_staff.dart`

Then archive and upload each app separately in App Store Connect.

## 3) Backend URL

Before release, set production API:

```bash
--dart-define=API_BASE_URL=https://your-domain.com/api/v1
```

Example:

```bash
flutter build appbundle --flavor user --target lib/main.dart --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```
