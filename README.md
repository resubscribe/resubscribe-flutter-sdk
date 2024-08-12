# Resubscribe Flutter SDK

Flutter SDK for [Resubscribe](https://resubscribe.ai).

## Installation

[https://pub.dev/packages/resubscribe_flutter_sdk](https://pub.dev/packages/resubscribe_flutter_sdk)

## Usage

Import the Resubscribe package.

```dart
import 'package:resubscribe_flutter_sdk/resubscribe_flutter_sdk.dart';
```

Call the `ResubscribeSDK` widget.

```dart
ResubscribeSDK.openWithConsent(
  context,
  aiType: '{{aiType}}', // Replace with the AI type
  uid: '{{userid}}', // Replace with the user ID
  slug: '{{slug}}', // Replace with your slug
  apiKey: '{{apiKey}}', // Replace with your API key
  // debugMode: true,
  // onClose: () {
  //   debugPrint('onClose');
  // },
);
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
    titleText: 'CUSTOM TITLE',
    descriptionText: 'CUSTOM CONTENT',
  ),
  // ...
)
```

#### Dialog modals

The dialogs are instances of Flutter's [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html). They can be customized via [ThemeData](https://api.flutter.dev/flutter/material/AlertDialog-class.html).

