# Damage Assessment System (Flutter)

Residents report damaged or dangerous areas; municipality admins review, accept/reject,
assign teams, and track progress. Prototype using local storage only (no backend, no sample data).

## Run it

Requires Flutter 3.24 or newer.

```bash
cd damage_assessment_system
flutter create --platforms=android,ios .   # generates android/ios folders (lib/ and pubspec stay as-is)
flutter pub get
flutter run
```

### iOS only: camera / gallery permissions
Add to `ios/Runner/Info.plist` inside `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Take a photo of the damaged area to include in your report.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose a photo of the damaged area to include in your report.</string>
```
Android needs no extra setup for `image_picker`.

## Branding and fonts
- Logo: `assets/images/das_logo.png` (declared in `pubspec.yaml`). It is shown unmodified on navy panels; app bars use only the round emblem of the same file.
- Font: Poppins, bundled in `assets/fonts/` (works offline).

## Photos
The photo is read as bytes (`image_picker`), stored locally as Base64 in `shared_preferences`
(one key per report) and shown with `Image.memory`. No files, no backend, works on Android, iOS and web.

## Try it

**Resident:** Home -> Report a Damage -> add photo, fill the form -> Submit -> My Reports.

**Admin:** tap the shield icon on the home screen, then log in with
`harvey` / `harvey14` (mock credentials, see `lib/services/auth_service.dart`).

## Structure

```
lib/
  main.dart
  models/    damage_report.dart, worker.dart, report_filters.dart
  services/  report_service.dart, auth_service.dart, storage_service.dart,
             photo_service.dart, theme_service.dart
  screens/splash_screen.dart
  screens/user/   home, report form, success, my reports
  screens/admin/  login, shell (nav), dashboard, reports, details, workers, settings, photo viewer
  widgets/   reusable cards, badges, buttons, dialogs
  theme/     app_theme.dart
  utils/     constants.dart (barangay list), formatters.dart
```

## Connecting a real backend later
Screens only talk to `ReportService`, `AuthService`, and `PhotoService`.
Replace the `StorageService` calls inside those classes with API calls
(and upload the photo bytes from `ReportService.submitReport`).

## Notes
- The app starts with zero reports. Use "Settings -> Delete all reports" to clear everything.
- Edit the barangay list in `lib/utils/constants.dart`.
- Admin credentials are hard-coded for the prototype only. Never ship real passwords in an app.
