import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResubscribeSDK extends StatefulWidget {
  final String aiType;
  final String uid;
  final String consent;
  final String slug;
  final VoidCallback onClose;
  final bool debugMode;
  final Color loadingColor;
  final Color backgroundColor;

  const ResubscribeSDK({
    Key? key,
    required this.aiType,
    required this.uid,
    this.consent = 'ask',
    required this.slug,
    required this.onClose,
    this.debugMode = false,
    this.loadingColor = Colors.black,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  _ResubscribeSDKState createState() => _ResubscribeSDKState();
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

    String path = 'chat';
    return Uri.parse('$base/$path/${widget.slug}')
        .replace(queryParameters: queryParams);
  }

  void onConsentAcquired() {
    setState(() {
      consentAcquired = true;
      isLoading = true;
      showCloseButton = true;
      backgroundColor = widget.backgroundColor;
    });
    _controller.loadRequest(buildUri());
    _controller.setBackgroundColor(Colors.transparent);

    // Future.delayed(const Duration(seconds: 2), () {
    //   if (mounted) {
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();

    // Reduce opacity of background color prop by 25%
    backgroundColor = widget.backgroundColor.withOpacity(0.75);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        if (widget.debugMode)
          debugPrint('* [${message.level}] ${message.message}');
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
              widget.onClose();
            }
            // if (json['type'] == 'consent') {
            //   setState(() {
            //     backgroundColor = widget.backgroundColor;
            //   });
            // }
          } catch (e) {
            if (widget.debugMode) {
              debugPrint('Error decoding JSON: $e');
            }
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog.fullscreen(
        backgroundColor: backgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              !consentAcquired
                  ? Center(
                      child: ResubscribeConsentModal(
                        aiType: widget.aiType,
                        onAccept: () {
                          onConsentAcquired();
                        },
                        onDecline: () {
                          widget.onClose();
                        },
                      ),
                    )
                  : Center(
                      child: WebViewWidget(
                        controller: _controller,
                      ),
                    ),
              if (isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: widget.loadingColor,
                    ),
                  ),
                ),
              if (showCloseButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    // show exit confirmation dialog
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Done giving feedback?'),
                            // content: const Text('You won\'t be able to return to this chat.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onClose();
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
  final String acceptText;
  final String declineText;
  final String titleOverride;
  final String contentOverride;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ResubscribeConsentModal({
    Key? key,
    required this.aiType,
    this.acceptText = 'Let\'s chat!',
    this.declineText = 'Not right now',
    this.titleOverride = '',
    this.contentOverride = '',
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  String getTitle() {
    if (titleOverride.isNotEmpty) {
      return titleOverride;
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
    if (titleOverride.isNotEmpty) {
      return titleOverride;
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
