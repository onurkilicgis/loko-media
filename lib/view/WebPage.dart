import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late WebViewController controller;
  double progress = 0;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          return false; // telefonun geri tuşu çalışmasın
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back)),
            actions: [
              IconButton(
                  onPressed: () => controller.reload(),
                  icon: Icon(Icons.refresh)),
              /*IconButton(
                  onPressed: () {
                    controller.clearCache();
                    CookieManager().clearCookies();
                  },
                  icon: Icon(Icons.clear))*/
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  color: Color(0xff80C783),
                  backgroundColor: Colors.black,
                ),
                Expanded(
                  child: WebView(
                    initialUrl: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    debuggingEnabled: false,
                    initialMediaPlaybackPolicy:
                        AutoMediaPlaybackPolicy.always_allow,
                    allowsInlineMediaPlayback: true,
                    onWebViewCreated: (controller) {
                      this.controller = controller;
                    },
                    onProgress: (progress) =>
                        setState(() => this.progress = progress / 100),
                    onWebResourceError: (websourceerror) {
                      print(websourceerror.domain.toString());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
