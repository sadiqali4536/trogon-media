class VideoModel {
  final int id;
  final String title;
  final String description;
  final String videoType; 
  final String videoUrl;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoType,
    required this.videoUrl,
  });

 // get api datas to app from video
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      videoType: json['video_type'],
      videoUrl: json['video_url'],
    );
  }
}
