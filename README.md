# FlutterBomberMan

## Live Demo

Here's an Demo application: [Demo](https://flutterbomberman.web.app/)


## Build
flutter build web --web-renderer canvaskit
firebase deploy


# Emulator
firebase emulators:start
ngrok http 4400

# Test Deploy
firebase hosting:channel:deploy test_feature

# Run
flutter run -d chrome