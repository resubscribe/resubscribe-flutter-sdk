# Resubscribe Flutter SDK

Flutter SDK for [Resubscribe](https://resubscribe.ai).

## Installation

[https://pub.dev/packages/resubscribe_flutter_sdk](https://pub.dev/packages/resubscribe_flutter_sdk)

## Usage

Call `ResubscribeSDK.openWithConsent(...)` with the build context passed in. Calling this does the following:

1. Opens a consent pop up asking the user if they'd like to chat
2. If the user clicks "Let's chat!", then the Resubscribe web view is opened in-app.

``` dart
ResubscribeSDK.openWithConsent(
  context: context,
  aiType: 'churn', // Replace with the AI type
  uid: 'abcdef', // Replace with the user ID
  slug: 'slug', // Replace with your slug
  // optional parameters
  debugMode: true,
  onClose: () => setState(() {
    _showWebView = false;
  }),
  loadingColor: Colors.black,
  backgroundColor: Colors.white,
  consentOptions: const ResubscribeConsentOptions(
    acceptText: 'Let\'s chat!',
    declineText: 'Not right now',
    // titleOverride: 'ADD A CUSTOM TITLE',
    // contentOverride: 'ADD A CUSTOM DESCRIPTION',
  ),
);
```

### Android

Make sure your device has the following permissions:

```
<uses-permission android:name="android.permission.INTERNET" />
```

### Customization

#### Dialog modals

The dialogs are instances of Flutter's [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html). They can be customized via [ThemeData](https://api.flutter.dev/flutter/material/AlertDialog-class.html);

