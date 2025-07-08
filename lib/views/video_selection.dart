import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trogon_media/models/video_model.dart';
import 'package:trogon_media/utils/services/api_services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VideoSelection extends StatelessWidget {
  final int moduleId;
  final String moduleTitle;

  const VideoSelection({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      moduleTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_left_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                  ),
                ),
                child: FutureBuilder<List<VideoModel>>(
                  future: api.fetchVideos(moduleId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final videos = snapshot.data!;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth >= 800) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            mainAxisExtent: 300,
                          ),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            return GestureDetector(
                              onTap: () => _showVideoPopup(context, video),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        video.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                "https://trogonmedia.com/assets/images/logo.png",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 150,
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                        const Positioned.fill(
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_fill,
                                              size: 50,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        video.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        video.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
void _showVideoPopup(BuildContext context, VideoModel video) async {
  try {
    // If on Web and video is YouTube, show alert dialog of player
    if (kIsWeb && video.videoType.toLowerCase() == 'youtube') {
      _showErrorDialog(
        context,
        "YouTube video playback is not supported on Web platform. Please use a mobile device to watch this video.",
      );
      return;
    }

    Widget videoWidget;

    if (video.videoType.toLowerCase() == 'youtube') {
      final videoId = YoutubePlayer.convertUrlToId(video.videoUrl);
      if (videoId == null || videoId.isEmpty) {
        throw Exception("Invalid YouTube URL");
      }

      videoWidget = YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true),
        ),
        showVideoProgressIndicator: true,
      );
    } else if (video.videoType.toLowerCase() == 'vimeo') {
      final videoId = _extractVimeoId(video.videoUrl);
      if (videoId.isEmpty) {
        throw Exception("Invalid Vimeo URL");
      }

      videoWidget = VimeoVideoPlayer(
        videoId: videoId,
        isAutoPlay: true,
      );
    } else {
      throw Exception("Unsupported video type");
    }

    showDialog(
      barrierColor: Colors.black,
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        content: AspectRatio(
          aspectRatio: 16 / 9,
          child: videoWidget,
        ),
      ),
    );
  } catch (e) {
    _showErrorDialog(context, "Unable to play this video.\n\nReason: ${e.toString()}");
  }
}


  // Show generic error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Video Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Extract Vimeo ID from URL
  String _extractVimeoId(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    } catch (e) {
      return '';
    }
  }
}
