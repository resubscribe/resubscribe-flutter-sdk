import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void noop() {}

class ResubscribeConsentOptions {
  final String acceptText;
  final String declineText;
  final String titleText;
  final String descriptionText;

  const ResubscribeConsentOptions({
    this.acceptText = 'Let\'s chat!',
    this.declineText = 'Not right now',
    this.titleText = '',
    this.descriptionText = '',
  });
}

class ResubscribeSDK extends StatefulWidget {
  final String aiType;
  final String uid;
  final String slug;
  final String apiKey;
  final VoidCallback onClose;
  final bool debugMode;
  final Color loadingColor;
  final Color backgroundColor;
  final ResubscribeConsentOptions consentOptions;

  const ResubscribeSDK({
    Key? key,
    required this.aiType,
    required this.uid,
    required this.slug,
    required this.apiKey,
    required this.onClose,
    required this.debugMode,
    required this.loadingColor,
    required this.backgroundColor,
    required this.consentOptions,
  });

  static void openWithConsent(BuildContext context, {
    required String aiType,
    required String uid,
    required String slug,
    required String apiKey,
    onClose = noop,
    debugMode = false,
    loadingColor = Colors.black,
    backgroundColor = Colors.white,
    consentOptions = const ResubscribeConsentOptions(),
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResubscribeSDK(
          aiType: aiType,
          uid: uid,
          slug: slug,
          apiKey: apiKey,
          onClose: onClose,
          debugMode: debugMode,
          loadingColor: loadingColor,
          backgroundColor: backgroundColor,
          consentOptions: consentOptions,
        ),
      ),
    );
  }

  @override
  State<ResubscribeSDK> createState() => _ResubscribeSDKState();
}

class _ResubscribeSDKState extends State<ResubscribeSDK> {
  late final WebViewController _controller;
  bool isLoading = false;
  bool showCloseButton = false;
  bool consentAcquired = false;
  Color backgroundColor = Colors.white;

  Uri buildUri() {
    const base = 'https://app.resubscribe.ai';

    final queryParams = {
      'ait': widget.aiType,
      'uid': widget.uid,
      'iframe': 'true',
      'hideclose': 'true'
    };
    final fragment = 'apiKey=${widget.apiKey}';

    String path = 'chat';
    return Uri.parse('$base/$path/${widget.slug}')
        .replace(queryParameters: queryParams, fragment: fragment);
  }
  
  void onCloseViaConsent() {
    widget.onClose();
    Navigator.of(context).pop();
  }

  void onCloseViaWebView() {
    widget.onClose();
    // close the dialog
    Navigator.of(context).pop();
    // close the webview
    Navigator.of(context).pop();
  }

  void onConsentAcquired() {
    setState(() {
      consentAcquired = true;
      isLoading = true;
      showCloseButton = true;
    });
    _controller.loadRequest(buildUri());
    _controller.setBackgroundColor(Colors.transparent);
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        if (widget.debugMode) {
          debugPrint('* [${message.level}] ${message.message}');
        }
      })
      // ..setOnJavaScriptAlertDialog((request) {
      //   debugPrint('Alert: ${request.message}');
      //   return Future.value(request.message);
      // })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          if (widget.debugMode) {
            debugPrint('Page finished loading: $url');
          }
          setState(() {
            isLoading = false;
          });
        },
        onWebResourceError: (WebResourceError error) {
          if (widget.debugMode) {
            debugPrint('Error loading web resource: ${error.errorCode} ${error.description}');
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          if (widget.debugMode) {
            debugPrint('Navigation requested: ${request.url}');
          }
          setState(() {
            isLoading = true;
          });
          return NavigationDecision.navigate;
        },
      ))
      ..addJavaScriptChannel(
        'resubscribe',
        onMessageReceived: (JavaScriptMessage message) {
          if (widget.debugMode) {
            debugPrint('Message received from JavaScript: ${message.message}');
          }
          try {
            var json = jsonDecode(message.message);
            if (json['type'] == 'close') {
              onCloseViaWebView();
            }
          } catch (e) {
            debugPrint('Error decoding JSON: $e');
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog.fullscreen(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              !consentAcquired
                  ? Center(
                      child: ResubscribeConsentModal(
                        aiType: widget.aiType,
                        onAccept: onConsentAcquired,
                        onDecline: () {
                          onCloseViaConsent();
                        },
                        acceptText: widget.consentOptions.acceptText,
                        declineText: widget.consentOptions.declineText,
                        titleText: widget.consentOptions.titleText,
                        descriptionText: widget.consentOptions.descriptionText,
                      ),
                    )
                  : Center(
                      child: WebViewWidget(
                        controller: _controller,
                      ),
                    ),
              if (isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  ),
                ),
              if (showCloseButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Done giving feedback?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // close the confirmation dialog
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  onCloseViaWebView();
                                },
                                child: const Text('Exit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResubscribeConsentModal extends StatelessWidget {
  final String aiType;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String acceptText;
  final String declineText;
  final String titleText;
  final String descriptionText;

  const ResubscribeConsentModal({
    Key? key,
    required this.aiType,
    required this.onAccept,
    required this.onDecline,
    this.acceptText = 'Let\'s chat!',
    this.declineText = 'Not right now',
    this.titleText = '',
    this.descriptionText = '',
  });

  String getTitle() {
    if (titleText.isNotEmpty) {
      return titleText;
    }
    if (aiType == 'intent') {
      return 'Not ready to pay?';
    }
    if (aiType == 'churn') {
      return 'We\'re sorry to see you go';
    }
    if (aiType == 'delete') {
      return 'We\'re sorry to see you go';
    }
    if (aiType == 'subscriber') {
      return 'Would you like to tell us about your experience?';
    }
    return 'Would you like to tell us about your experience?';
  }

  String getDescription() {
    if (descriptionText.isNotEmpty) {
      return descriptionText;
    }
    if (aiType == 'intent') {
      return 'Can we ask you a few questions? It should only take a few minutes.';
    }
    if (aiType == 'churn') {
      return 'Can we ask you a few questions? It should only take a few minutes.';
    }
    if (aiType == 'delete') {
      return 'Can we ask you a few questions? It should only take a few minutes.';
    }
    if (aiType == 'subscriber') {
      return 'Can we ask you a few questions? It should only take a few minutes.';
    }
    return 'Can we ask you a few questions? It should only take a few minutes.';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getTitle()),
      content: Text(getDescription()),
      actions: <Widget>[
        TextButton(
          onPressed: onDecline,
          child: Text(declineText),
        ),
        TextButton(
          onPressed: onAccept,
          child: Text(acceptText),
        ),
      ],
    );
  }
}
