# Resubscribe Flutter SDK

Flutter SDK for [Resubscribe](https://resubscribe.ai).

## Installation

[https://pub.dev/packages/resubscribe_flutter_sdk](https://pub.dev/packages/resubscribe_flutter_sdk)

## Usage

In the scaffold of your app, add the following:

```dart
if (showResubscribe)
  ResubscribeSDK(
    loadingColor: Colors.black,
    backgroundColor: Colors.white,
    aiType: 'intent', // Replace with the AI type
    uid: '{userid}', // Replace with the user ID
    consent: 'ask',
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