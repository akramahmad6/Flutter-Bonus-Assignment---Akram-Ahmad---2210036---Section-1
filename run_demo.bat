@echo off
echo Running Flutter demo helper...
flutter pub get
flutter analyze
flutter run -d emulator-5554
pause
