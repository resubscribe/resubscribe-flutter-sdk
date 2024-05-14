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

### Customization

#### Consent options

The text on the consent popup is already customized to the AI type you choose.

However, if you want to override these values, then you can pass in the `consentOptions` to the `ResubscribeSDK`.

```dart
ResubscribeSDK(
  // ...
  consentOptions: const ResubscribeConsentOptions(
    acceptText: 'Let\'s chat!',
    declineText: 'Not right now',
    titleOverride: 'CUSTOM TITLE',
    contentOverride: 'CUSTOM CONTENT',
  ),
  // ...
)
```

#### Dialog modals

The dialogs are instances of Flutter's [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html). They can be customized via [ThemeData](https://api.flutter.dev/flutter/material/AlertDialog-class.html);

