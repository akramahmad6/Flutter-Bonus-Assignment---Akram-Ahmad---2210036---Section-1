# Firebase setup

The Firestore CRUD code uses the `coffee_records` collection and is ready to use
once it is connected to your own Firebase project.

1. Create a project in the [Firebase console](https://console.firebase.google.com/)
   and enable **Cloud Firestore** in test mode.
2. Add an Android app with package name `com.example.summer_iub_app` (or change
   `applicationId` in `android/app/build.gradle.kts` first). Download the
   generated `google-services.json` into `android/app/`.
3. Register the other platforms you intend to run, then run
   `dart pub global activate flutterfire_cli` and `flutterfire configure` from
   this project. This generates `lib/firebase_options.dart`; update `main.dart`
   to use `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
4. In Firestore Rules, paste and publish [firestore.rules](firestore.rules).
5. Run `flutter pub get` and `flutter run`.

The included development rule permits anyone to read or write the database. Do
not use it in a production app.
