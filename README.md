# Resubscribe Flutter SDK

Flutter SDK for [Resubscribe](https://resubscribe.ai).

## Installation

[https://pub.dev/packages/resubscribe_flutter_sdk](https://pub.dev/packages/resubscribe_flutter_sdk)

## Usage

Add a `showResubscribe` variable to your state.

```dart
bool showResubscribe = false;
```

Trigger the `ResubscribeSDK` by setting `showResubscribe` to true.
```dart
setState(() {
  showResubscribe = true;
});
```

Add the `ResubscribeSDK` to your widget tree.

```dart
if (showResubscribe)
  ResubscribeSDK(
    loadingColor: Colors.black,
    backgroundColor: Colors.white,
    aiType: 'intent', // Replace with the AI type
    uid: '{userid}', // Replace with the user ID
    slug: 'test', // Replace with your slug
    debugMode: true,
    onClose: () {
      setState(() {
        showResubscribe = false;
      });
    },
  ),
```

### Android

Make sure your device has the following permissions:

```
<uses-permission android:name="android.permission.INTERNET" />
```