library social_embed_webview;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_embed_webview/platforms/social-media-generic.dart';
import 'package:social_embed_webview/utils/common-utils.dart';
import 'package:social_embed_webview/utils/constants.dart';
import 'package:social_embed_webview/utils/shimmar/shimmer_effect_embed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class SocialEmbed extends StatefulWidget {
  final SocialMediaGenericEmbedData socialMediaObj;
  final Color? backgroundColor;
  const SocialEmbed(
      {Key? key, required this.socialMediaObj, this.backgroundColor})
      : super(key: key);

  @override
  _SocialEmbedState createState() => _SocialEmbedState();
}

class _SocialEmbedState extends State<SocialEmbed> with WidgetsBindingObserver {
  double _height = 1;
  WebViewPlusController? wbController;
  late String htmlBody;

  @override
  void initState() {
    super.initState();
    // htmlBody = ;
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    if (widget.socialMediaObj.supportMediaControll)
      WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    if (widget.socialMediaObj.supportMediaControll)
      WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        wbController!.webViewController.evaluateJavascript(widget.socialMediaObj.stopVideoScript);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        wbController!.webViewController.evaluateJavascript(widget.socialMediaObj.pauseVideoScript);
        break;
    }
  }
  bool isLoading=true;

  @override
  Widget build(BuildContext context) {
    final wv = WebViewPlus(
        initialUrl: '',
        javascriptChannels: <JavascriptChannel>[_getHeightJavascriptChannel()].toSet(),
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: (wbc) {
          wbController = wbc;
          wbController!.loadUrl(htmlToURI(getHtmlBody()));

        },
        onPageFinished: (str) async{
       /*   if(wbController!=null) {
            final color = colorToHtmlRGBA(getBackgroundColor(context));
            wbController!.evaluateJavascript(
                'document.body.style= "background-color: $color"');
            if (widget.socialMediaObj.aspectRatio == null)
              wbController!
                  .evaluateJavascript('setTimeout(() => sendHeight(), 0)');

            double height =   double.parse(await wbController!.evaluateJavascript("document.documentElement.scrollHeight;"));
            print("onPageFinished");
            Timer(Duration(seconds: 2), () {setState(() {
              isLoading = false;
              _height = height;
              // _getHeightJavascriptChannel();
            });
            });
          }*/
       Timer(Duration(seconds: 2), () {
          wbController!.getHeight().then((double height) {
            print("finalHeight: " + height.toString());
            setState(() {
              _height = height + widget.socialMediaObj.bottomMargin;
              isLoading = false;
            });
          });
       });

        },
        navigationDelegate: (navigation) async {
         /* final url = navigation.url;
          if (navigation.isForMainFrame && await canLaunch(url)) {
            launch(url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;*/
          return NavigationDecision.prevent;
        });
    final ar = widget.socialMediaObj.aspectRatio;
    return Stack(
      children: <Widget>[
        (ar != null)
            ? ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 1.5,
            maxWidth: double.infinity,
          ),
          child: AspectRatio(aspectRatio: ar, child: wv),
        )
            : SizedBox(height: _height, child: wv),
        isLoading ? Center(child: ShimmerEffectEmbed(ar : widget.socialMediaObj.aspectRatio, height: _height,),)
            : SizedBox(),
      ],
    );
  }

  JavascriptChannel _getHeightJavascriptChannel() {
    return JavascriptChannel(
        name: 'PageHeight',
        onMessageReceived: (JavascriptMessage message) {
          _setHeight(double.parse(message.message));
        });
  }

  void _setHeight(double height) {
    setState(() {
      _height = height + widget.socialMediaObj.bottomMargin;
      print("height");
      print(height);
      print(_height);
    });
  }

  Color getBackgroundColor(BuildContext context) {
    return widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  }

  String getHtmlBody() => """
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            *{box-sizing: border-box;margin:0px; padding:0px;}
              #widget {
                        display: flex;
                        justify-content: center;
                        margin: 0 auto;
                        max-width:100%;
                    }      
          </style>
        </head>
        <body>
          <div id="widget" style="${widget.socialMediaObj.htmlInlineStyling}">${widget.socialMediaObj.htmlBody}</div>
          ${(widget.socialMediaObj.aspectRatio == null) ? dynamicHeightScriptSetup : ''}
          ${(widget.socialMediaObj.canChangeSize) ? dynamicHeightScriptCheck : ''}
        </body>
      </html>
    """;

  static const String dynamicHeightScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendHeight = () => PageHeight.postMessage(widget.clientHeight);
    </script>
  """;

  static const String dynamicHeightScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => sendHeight();
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;

  double getHeightSOcilaType(){
    var height;
    if(getHtmlBody().contains('instagram')){
      height = 624;
    }
    return height!;
  }
}
