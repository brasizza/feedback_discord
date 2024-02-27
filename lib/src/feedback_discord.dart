import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// This is an extension to make it easier to call
/// [showAndUploadToDiscord].
extension BetterFeedbackDiscord on FeedbackController {
  void showAndUploadToDiscord({
    required String channel,
    required String discordUrl,
    http.Client? client,
    required List<String> customData,
  }) {
    show(uploadToDiscord(
        channel: channel,
        discordUrl: discordUrl,
        client: client,
        customData: customData));
  }
}

/// See [BetterFeedbackX.showAndUploadToDiscord].
/// This is just [visibleForTesting].
@visibleForTesting
OnFeedbackCallback uploadToDiscord({
  required String channel,
  required String discordUrl,
  http.Client? client,
  List<String>? customData,
}) {
  final httpClient = client ?? http.Client();
  final baseUrl = discordUrl;

  return (UserFeedback feedback) async {
    final uri = Uri.parse(
      baseUrl,
    );
    final uploadRequest = http.MultipartRequest('POST', uri)
      ..fields['content'] = "${feedback.text}\n${customData?.join("\n")}"
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        feedback.screenshot,
        filename: 'feedback.png',
        contentType: MediaType('image', 'png'),
      ));

    await httpClient.send(uploadRequest);
  };
}
