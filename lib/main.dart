// ignore: unused_import
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:test_project/firebase_options.dart';
import 'package:test_project/game_page.dart';
import 'package:test_project/link_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  final linkRepository = LinkRepository();
  remoteConfig.onConfigUpdated.listen((event) async {
    await remoteConfig.activate();

    // Use the new config values here.
    final link = remoteConfig.getString('link');
    debugPrint('Link: $link');
    await linkRepository.saveLink(link);
  });

  runApp(const GamePage());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const link = 'https://www.yandex.ru/';
    return MaterialApp(
      title: 'My First Flutter App',
      debugShowCheckedModeBanner: false,
      home: Visibility(
        visible: link.isEmpty,
        replacement: const MyWebViewPage(link: link),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My First Flutter App'),
          ),
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Open webview'),
            ),
          ),
        ),
      ),
    );
  }
}

class MyWebViewPage extends StatefulWidget {
  const MyWebViewPage({
    super.key,
    required this.link,
  });

  final String link;

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final PlatformWebViewControllerCreationParams params;
  late final WebViewController controller;

  @override
  void initState() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
    }
    return Future.value(false);
  }
}
