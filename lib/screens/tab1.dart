import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:g14/screens/recipegenerator.dart';

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  static const String key = "AIzaSyA8OXpQMoeDgbb7nkwX4mDpjeCh4UmQkOQ";

  YoutubeAPI youtube = YoutubeAPI(key);
  List<YouTubeVideo> videoResult = [];

  String selectedQuery = "簡単レシピ"; // 初期値を簡単レシピに設定

  Future<void> callAPI() async {
    videoResult = await youtube.search(
      selectedQuery,
      order: 'relevance',
      videoDuration: 'any',
      regionCode: 'JP',
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 選択肢を表示するDropdownButton
        DropdownButton<String>(
          value: selectedQuery,
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(
              value: "簡単レシピ",
              child: Text("簡単レシピ"),
            ),
            DropdownMenuItem<String>(
              value: "和食　レシピ",
              child: Text("和食"),
            ),
            DropdownMenuItem<String>(
              value: "洋食　レシピ",
              child: Text("洋食"),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              selectedQuery = newValue ?? "";
              callAPI(); // 選択肢が変更されたらAPIを再呼び出し
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: videoResult.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading:
                Image.network(videoResult[index].thumbnail.small.url ?? ''),
                title: Text(videoResult[index].title),
                subtitle: Text(videoResult[index].channelTitle),
                onTap: () {
                  String? selectedVideoId = videoResult[index].id;
                  if (selectedVideoId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeGenerator(
                          videoId: selectedVideoId,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
