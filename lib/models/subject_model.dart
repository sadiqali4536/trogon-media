class SubjectModel {
  final int id;
  final String title;
  final String description;
  final String image;

  SubjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }
}





