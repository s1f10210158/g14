import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeGenerator2 extends StatefulWidget {
  final String videoId;

  RecipeGenerator2({required this.videoId});

  @override
  _RecipeGenerator2State createState() => _RecipeGenerator2State();
}

class _RecipeGenerator2State extends State<RecipeGenerator2> {
  List<Map<String, dynamic>> subtitles = [];

  @override
  void initState() {
    super.initState();
    _fetchSubtitles();
  }

  Future<void> _fetchSubtitles() async {
    try {
      final functionUrl = 'https://asia-northeast1-dotted-crane-403823.cloudfunctions.net/get_transcript?video_id=${widget.videoId}';
      final response = await http.get(Uri.parse(functionUrl));

      if (response.statusCode == 200) {
        print('Full Response (_fetchSubtitles): ${response.body}');
        print('Response Length (_fetchSubtitles): ${response.body.length}');
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> transcript = data['transcript'];
        setState(() {
          subtitles = transcript.map<Map<String, dynamic>>((subtitleLine) {
            return {
              'text': subtitleLine['text'],
              'start': subtitleLine['start'],
              'duration': subtitleLine['duration']
            };
          }).toList();
        });

        // 字幕を取得した後、INIAD APIに送信
        _sendMessage(subtitles.map((subtitle) => subtitle['text']).join(' '));

      } else {
        print("Error fetching subtitles: ${response.body}");
      }
    } catch (e) {
      print("Error fetching subtitles: $e");
    }
  }

  Future<void> _sendMessage(String text) async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions';
    final String iniad_apiKey = 'UeOuO6C3PXFbiJDxM68LpE94iE9R3SuoFCQtmimdM9_wd8S-FAwRlAKzjNqNvWneji161chF5LpBDI7GtHZS2YQ';

    final headers = {
      'Authorization': 'Bearer $iniad_apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': '日本語で対応して下さい。あなたは優秀なシェフです。あなたにyoutubeの字幕を渡します。その内容から材料と調理工程を教えて下さい。'
        },
        {
          'role': 'user',
          'content': text,
        },
      ],
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: body,
    );

    print('Full Response (_sendMessage): ${response.body}');
    print('Response Length (_sendMessage): ${response.body.length}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final String reply = data['choices'][0]['message']['content'].trim();
      print('Decoded text: $reply');
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('INIAD APIに送信中...')),
      body: Center(
        child: CircularProgressIndicator(), // ローディングインジケータを表示
      ),
    );
  }
}
