import 'social-media-generic.dart';

class TelegramEmbedData extends SocialMediaGenericEmbedData {
  final String embedHtml;

  const TelegramEmbedData({required this.embedHtml})
      : super(canChangeSize: true, bottomMargin: -10);

  @override
  String get htmlScriptUrl => 'https://telegram.org/js/telegram-widget.js';

  @override
  String get htmlBody => embedHtml + htmlScript;
}
