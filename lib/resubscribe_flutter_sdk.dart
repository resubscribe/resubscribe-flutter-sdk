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
  bool isLoading = true;
  bool showCloseButton = false;
  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // Reduce opacity of background color prop by 25%
    backgroundColor = widget.backgroundColor.withOpacity(0.75);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCloseButton = true;
        });
      }
    });

    final base = 'https://app.resubscribe.ai';
    // final base = 'http://localhost:3000';

    final queryParams = {
      'ait': widget.aiType,
      'uid': widget.uid,
      'consent': widget.consent,
      'iframe': 'true',
      'hideclose': 'true'
    };

    String path = 'chat';
    if (widget.consent == 'ask') {
      path = 'consent';
    }
    final uri = Uri.parse('$base/$path/${widget.slug}').replace(queryParameters: queryParams);

    _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setOnConsoleMessage((message) {
          if (widget.debugMode)
            debugPrint('* [${message.level}] ${message.message}');
        })
        // ..setOnJavaScriptAlertDialog((request) {
        //   debugPrint('Alert: ${request.message}');
        //   return Future.value(request.message);
        // })
        ..loadRequest(uri)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (widget.debugMode)
                debugPrint('Page finished loading: $url');
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              if (widget.debugMode)
                debugPrint('Error loading web resource: ${error.errorCode} ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (widget.debugMode)
                debugPrint('Navigation requested: ${request.url}');
              setState(() {
                isLoading = true;
              });
              return NavigationDecision.navigate;
            },
          )
        )
        ..addJavaScriptChannel(
          'resubscribe',
          onMessageReceived: (JavaScriptMessage message) {
            if (widget.debugMode)
              debugPrint('Message received from JavaScript: ${message.message}');
            try {
              var json = jsonDecode(message.message);
              if (json['type'] == 'close') {
                widget.onClose();
              }
              if (json['type'] == 'consent') {
                setState(() {
                  backgroundColor = widget.backgroundColor;
                });
              }
            } catch (e) {
              if (widget.debugMode)
                debugPrint('Error decoding JSON: $e');
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.opened) {
    //   return const SizedBox.shrink();
    // }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog.fullscreen(
        backgroundColor: backgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
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
