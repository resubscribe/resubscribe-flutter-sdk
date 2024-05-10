import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResubscribeSDK extends StatefulWidget {
  final String aiType;
  final String uid;
  final String consent;
  final String slug;
  final bool opened;
  final VoidCallback onClose;
  final Color loadingColor;
  final Color backgroundColor;

  const ResubscribeSDK({
    Key? key,
    required this.aiType,
    required this.uid,
    this.consent = 'given',
    required this.slug,
    required this.opened,
    required this.onClose,
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
      setState(() {
        showCloseButton = true;
      });
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
    final uri = Uri.parse('$base/chat/${widget.slug}').replace(queryParameters: queryParams);

    _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(uri)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
              setState(() {
                isLoading = false;
              });
            },
            // onNavigationRequest: (NavigationRequest request) {
            //   debugPrint('Navigation requested: ${request.url}');
            //   return NavigationDecision.navigate;
            // },
          )
        )
        ..addJavaScriptChannel(
          'parent',
          onMessageReceived: (JavaScriptMessage message) {
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
              debugPrint('Error decoding JSON: $e');
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.opened) {
      return const SizedBox.shrink();
    }

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
                    onPressed: widget.onClose,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
