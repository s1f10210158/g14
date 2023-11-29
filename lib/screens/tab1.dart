import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:g14/screens/recipegenerator2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:hyper_effects/hyper_effects.dart';


class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  static const String key = "AIzaSyAd6OIW60UHOBRO_10VhujI6FujyBQsTB4";
  YoutubeAPI youtube = YoutubeAPI(key, maxResults: 20, type: 'video');
  List<YouTubeVideo> videoResult = [];
  bool _isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> callAPI(String query) async {
    setState(() {
      _isLoading = true;
    });

    List<YouTubeVideo> videos = await youtube.search(query, order: 'relevance', videoDuration: 'any', regionCode: 'JP');

    List<YouTubeVideo> videosWithCaptions = [];
    for (var video in videos) {
      if (await checkForCaptions(video.id)) {
        videosWithCaptions.add(video);
      }
    }

    setState(() {
      videoResult = videosWithCaptions;
      _isLoading = false;
    });
  }

  Future<bool> checkForCaptions(String? videoId) async {
    if (videoId == null) return false;

    final response = await http.post(
      Uri.parse('https://asia-northeast1-dotted-crane-403823.cloudfunctions.net/youtube_subtitles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'video_ids': [videoId]}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['captions'][videoId] ?? false;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'YouTube検索',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      callAPI(searchController.text);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  callAPI(value);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videoResult.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      videoResult[index].thumbnail.small.url ?? '',
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                      width: 150, // Set the width to your desired size
                      height: 150, // Set the height to your desired size
                    ).scrollTransition(
                          (context, widget, event) => widget
                          .blur(
                        switch (event.phase) {
                          ScrollPhase.identity => 0,
                          ScrollPhase.topLeading => 10,
                          ScrollPhase.bottomTrailing => 10,
                        },
                      )
                          .scale(
                        switch (event.phase) {
                          ScrollPhase.identity => 1,
                          ScrollPhase.topLeading => 0.9,
                          ScrollPhase.bottomTrailing => 1,
                        },
                      ),
                    ),
                    title: Text(videoResult[index].title),
                    onTap: () {
                      String? selectedVideoId = videoResult[index].id;
                      if (selectedVideoId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeGenerator2(videoId: selectedVideoId),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        _isLoading
            ? Center(child: Image.asset('assets/gif/road.gif')) // ロード中はGIFを表示
            : SizedBox.shrink(), // ロード完了後は表示しない
      ],
    );
  }
}