import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url});
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;

  bool jumping = false;

  bool isCanBack = false;
  bool isCanForward = false;
  double bottomSize = 50;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print('>> 用户点击链接：${request.url}');
            String url = request.url;
            if (url.startsWith('http://')) {
              print('>>> ⚠️ 已阻止加载明文链接：$url');
              String secureUrl = url.replaceFirst('http://', 'https://');
              print('>> 🌐 拦截 http，改为 https 加载：$secureUrl');
              controller.loadRequest(Uri.parse(secureUrl));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onProgress: (int progress) {
            // Update loading bar.
            print(">> progress:  $progress");
          },
          onPageStarted: (String url) {
            isCan();
            jumping = true;
            if (mounted) {
              setState(() {});
            }
            print(">> onPageStarted:  $url");
          },
          onPageFinished: (String url) {
            jumping = false;
            if (mounted) {
              setState(() {});
            }
            print(">> onPageFinished:  $url");
          },
          onHttpError: (HttpResponseError error) {
            print(">> onHttpError: $error");
          },
          onWebResourceError: (WebResourceError error) {
            print(">> onWebResourceError: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    isCan();
    print(">>> URL: ${widget.url}");
    super.initState();
  }

  void isCan() async {
    isCanBack = await controller.canGoBack();
    isCanForward = await controller.canGoForward();
    if (isCanBack || isCanForward) {
      bottomSize = 50;
    } else {
      bottomSize = 0;
    }
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!isCanBack) {
          Navigator.pop(context);
          return;
        }
        controller.goBack();
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: statusBarHeight),
            SizedBox(
              height: 100.h - statusBarHeight - bottomSize,
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      color: jumping ? Color(0x00CEF3EE) : Color(0xFFEEFBFA),
                      child: IconButton(
                        onPressed: () {
                          if (isCanBack) {
                            controller.goBack();
                            return;
                          }
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Platform.isIOS
                              ? Icons.arrow_back_ios_new
                              : Icons.arrow_back,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isCanBack || isCanForward)
              Container(
                height: bottomSize,
                color: Colors.white,
                child: Row(
                  children: [
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    //   icon: Icon(
                    //     Global.i.isApple
                    //         ? Icons.arrow_back_ios_new
                    //         : Icons.arrow_back,
                    //   ),
                    // ),
                    Expanded(child: Container()),
                    if (isCanBack || isCanForward)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: isCanBack
                            ? () {
                                controller.goBack();
                              }
                            : null,
                      ),
                    if (isCanBack || isCanForward)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: isCanForward
                            ? () {
                                controller.goForward();
                              }
                            : null,
                      ),
                    Expanded(flex: 1, child: Container()),
                    // SizedBox(width: 50),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
