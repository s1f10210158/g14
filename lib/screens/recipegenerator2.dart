import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class RecipeGenerator2 extends StatefulWidget {
  final String videoId;

  RecipeGenerator2({required this.videoId});

  @override
  _RecipeGenerator2State createState() => _RecipeGenerator2State();
}

class _RecipeGenerator2State extends State<RecipeGenerator2> {
  List<Map<String, dynamic>> subtitles = []; // 型を明示的に指定

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
      } else {
        print("Error fetching subtitles: ${response.body}");
      }
    } catch (e) {
      print("Error fetching subtitles: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('字幕')),
      body: ListView.builder(
        itemCount: subtitles.length,
        itemBuilder: (context, index) {
          final subtitle = subtitles[index];
          return ListTile(
            title: Text(subtitle['text']),  // 辞書のキーを使用してアクセス
            subtitle: Text('${subtitle['start']} - ${subtitle['duration']}'),
          );
        },
      ),
    );
  }
}