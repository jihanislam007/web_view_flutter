import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

class WebAllView extends StatefulWidget {
  final String url;
  const WebAllView({Key? key, required this.url}) : super(key: key);

  @override
  _WebAllViewState createState() => _WebAllViewState();
}

class _WebAllViewState extends State<WebAllView> {

  InAppWebViewController? _webViewController;
  double progress = 0;
  String url = '';

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        useOnDownloadStart: true,
      ),
      android: AndroidInAppWebViewOptions(
        initialScale: 100,
        useShouldInterceptRequest: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: SafeArea(
      child: Container(
        margin: EdgeInsets.only(left: 12,right: 12),
        child: Column(
          children: [
            progress < 1.0
                ? LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                  )
                : Center(),
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.url),
                  headers: {},
                ), // "https://unsplash.com/photos/odxB5oIG_iA"
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onDownloadStart: (controller, url) async {
                  // downloading a file in a webview application
                  print("onDownloadStart $url");
                  await FlutterDownloader.enqueue(
                    url: url.toString(), // url to download
                    savedDir: (await getExternalStorageDirectory())!.path,
                    // the directory to store the download
                    fileName: 'downloads',
                    headers: {},
                    showNotification: true,
                    openFileFromNotification: true,
                  );
                },
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
            ),
            ButtonBar(
              buttonAlignedDropdown: true,
              buttonPadding: EdgeInsets.all(2),
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () {
                    _webViewController?.goBack();
                  },
                ),
                ElevatedButton(
                  child: Icon(Icons.refresh),
                  onPressed: () {
                    _webViewController?.reload();
                  },
                ),
                ElevatedButton(
                  child: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _webViewController?.goForward();
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    ));
  }
}
