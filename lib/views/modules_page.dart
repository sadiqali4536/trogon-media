
// import 'package:flutter/material.dart';
// import 'package:trogon_media/models/module_model.dart';
// import 'package:trogon_media/utils/services/api_services.dart';
// import 'package:trogon_media/views/video_selection.dart';
// import 'dart:math';

// class ModuleListPage extends StatelessWidget {
//   final int subjectId;
//   final String subjectTitle;

//    ModuleListPage({super.key, required this.subjectId, required this.subjectTitle});

//   Random random = Random();

//   @override
//   Widget build(BuildContext context) {
//     final api = ApiService();

//     return Scaffold(
//       backgroundColor: Colors.black,
     
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(subjectTitle,style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
//                     IconButton(onPressed: (){
//                       Navigator.pop(context);
//                     }, icon: Icon(Icons.keyboard_arrow_left_sharp,color: Colors.white,))
//                   ],
//                 ),
//               ),
//               Container(
                
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(50)
//                   )
//                 ),
//                 child: FutureBuilder<List<ModuleModel>>(
//                   future: api.fetchModules(subjectId),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) return Container(
//                       height: MediaQuery.of(context).size.height,
//                       child: const Center(child: CircularProgressIndicator(
//                         color: Colors.black,
//                       )));
//                     if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
//                     final modules = snapshot.data!;
                
//                   return  Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: ListView.builder(
//                     shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: modules.length,
//                       itemBuilder: (context, index) {
//                           final module = modules[index];
                        
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => VideoListPage(
//                                   moduleTitle: module.title,
//                                   moduleId: module.id,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             height: 180,
//                             width: MediaQuery.of(context).size.width,
//                             margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 6,
                                  
//                                 )
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
                                
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     module.title,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Text(
//                                     module.description,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 300,top: 50),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.black,
//                                       borderRadius: BorderRadius.circular(30)
//                                     ),
//                                     height: 40,
//                                     width: 45,
//                                     child: IconButton(onPressed: (){}, icon: Icon(Icons.add,color: Colors.white,))),
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
                    
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trogon_media/models/module_model.dart';
import 'package:trogon_media/utils/services/api_services.dart';
import 'package:trogon_media/views/video_selection.dart';

class ModulesPage extends StatelessWidget {
  final int subjectId;
  final String subjectTitle;

  ModulesPage({super.key, required this.subjectId, required this.subjectTitle});

  final Random random = Random();

  Future<void> saveToSchedule(ModuleModel module) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> existing = prefs.getStringList('schedules') ?? [];

    Map<String, dynamic> moduleMap = {
      "id": module.id,
      "title": module.title,
      "description": module.description,
    };

    // Avoid duplicate entries
    bool alreadyAdded = existing.any((item) {
      final map = json.decode(item);
      return map["id"] == module.id;
    });

    if (!alreadyAdded) {
      existing.add(json.encode(moduleMap));
      await prefs.setStringList('schedules', existing);
    }
  }

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
                    Text(subjectTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.keyboard_arrow_left_sharp, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(50)),
                ),
                child: FutureBuilder<List<ModuleModel>>(
                  future: api.fetchModules(subjectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(child: CircularProgressIndicator(color: Colors.black)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final modules = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final module = modules[index];

                          return GestureDetector(
                            onTap: () async {
                              // await saveToSchedule(module);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoSelection(
                                    moduleTitle: module.title,
                                    moduleId: module.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      module.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      module.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 300, top: 50),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      height: 40,
                                      width: 45,
                                      child: const Icon(Icons.play_arrow, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
}

