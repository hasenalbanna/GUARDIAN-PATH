Guardian Path Flutter App

This folder contains a Flutter scaffold to run the Guardian Path mobile prototype (Android/iOS).

Setup (on a machine with Flutter SDK installed):

1. Initialize platform folders (one-time):

```bash
cd flutter_app
flutter create .
```

2. Install packages:

```bash
flutter pub get
```

3. Create a `.env` file in `flutter_app/` with:

```
GP_API_KEY=YOUR_API_KEY
```

4. Run on an Android device/emulator:

```bash
flutter run
```

Notes:
- The app uses `flutter_map` with OpenStreetMap tiles.
- The assistant uses an HTTP POST to the Gemini endpoint; include a valid `GP_API_KEY` in `.env` to enable live requests.
- Do NOT commit your `.env` or real API keys to git.
