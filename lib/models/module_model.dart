class ModuleModel {
  final int id;
  final String title;
  final String description;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
  });

 // get api datas to app from module
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
    );
  }
}