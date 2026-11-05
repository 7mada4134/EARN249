# EARN249 — Flutter + Firebase MVP source

## Implemented in this source package
- Arabic/English language switch and dark green visual theme.
- Firebase initialization using the supplied Android Firebase configuration.
- Email/password account creation and sign-in.
- Phone number SMS verification and linking to the email account.
- New accounts are assigned `role: user`.
- Poll list, admin poll creation, user voting, one response per account, and basic admin response count.
- Firestore security rules template in `firestore.rules`.

## Critical Android package identifier
The Firebase configuration supplied by the project owner registers this exact application ID:
`Com.earn249.com`

Keep the Android `applicationId` exactly the same for this config, or register a new Android app in Firebase using a new lowercase ID and replace the config/options. Conventional lowercase package IDs are preferable, but changing it requires a matching new Firebase Android app.

## Generate Android platform files
This archive includes the Dart source and Firebase config but not Flutter's generated Gradle wrapper/platform scaffolding. On a computer with Flutter installed:

```bash
flutter create --platforms=android --org Com.earn249 .
```

Then inspect `android/app/build.gradle` (or `build.gradle.kts`) and ensure `applicationId` matches `Com.earn249.com`. Place the supplied `google-services.json` at `android/app/google-services.json` (already included in this archive). Add the Google Services Gradle plugin as required by the current FlutterFire setup instructions.

Then:

```bash
flutter pub get
flutter run
```

## Firebase Console setup required
1. Authentication → Sign-in method: enable Email/Password and Phone.
2. Authentication → Settings: configure authorized domains if applicable and SMS/phone verification settings. Phone auth may require billing/region support and test numbers during development.
3. Firestore Database: create database and publish the contents of `firestore.rules` as the security rules.
4. Create the first administrator securely: after the admin signs up normally, use Firebase Console to edit `users/{ADMIN_UID}` and change `role` from `user` to `admin`. Never expose an in-app role editor.
5. Create required Firestore indexes if the console reports a missing-index error.

## Important current limitations
- Push notifications (FCM) are not wired yet; only the dependency is present. This requires device token registration and a trusted server/Cloud Function to send messages when polls are published.
- Admin results currently show total response count; per-option analytics/export and poll targeting to selected users remain to be implemented.
- The poll feed currently shows all published polls to all signed-in users. Per-user targeting is not implemented yet.
- Validate that a response option belongs to the poll in trusted backend logic before production. For a production release, use Cloud Functions or equivalent trusted backend validation and tighten rules further.
- This source has not been compiled or device-tested in this environment. Build the APK on a machine with Flutter and Android SDK installed.

## Build release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`
