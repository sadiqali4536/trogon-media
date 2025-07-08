
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trogon_media/models/subject_model.dart';
import 'package:trogon_media/utils/services/api_services.dart';
import 'package:trogon_media/views/modules_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  final TextEditingController searchController = TextEditingController();

  Future<List<Schedule>> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('schedules') ?? [];
    return encoded.map((s) => Schedule.fromJson(jsonDecode(s))).toList();
  }

  Future<List<SubjectModel>> _fetchSubjects() => api.fetchSubjects();

  Future<Map<String, dynamic>> _loadData() async {
    // load both schedules and subjects in parallel
    final results = await Future.wait([
      _fetchSubjects(),
      _loadSchedules(),
    ]);

    return {
      'subjects': results[0] as List<SubjectModel>,
      'schedules': results[1] as List<Schedule>,
    };
  }

  void _showAddScheduleDialog(Function(List<Schedule>) onSchedulesUpdated, List<Schedule> currentSchedules) {
    final timeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Add New Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            CupertinoTextField(
              placeholder: "Time",
              controller: timeCtrl,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  timeCtrl.text = time.format(context);
                }
              },
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              placeholder: "Title",
              controller: titleCtrl,
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              placeholder: "Description",
              controller: descCtrl,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            child: const Text("Add"),
            onPressed: () async {
              final time = timeCtrl.text.trim();
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (time.isNotEmpty && title.isNotEmpty && desc.isNotEmpty) {
                final newSchedule = Schedule(time: time, title: title, description: desc);
                final updatedSchedules = List<Schedule>.from(currentSchedules)..add(newSchedule);

                // Save schedules to shared preferences
                final prefs = await SharedPreferences.getInstance();
                final encoded = updatedSchedules.map((s) => jsonEncode(s.toJson())).toList();
                await prefs.setStringList('schedules', encoded);

                onSchedulesUpdated(updatedSchedules);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(builder: (context) {
        // We use a Builder here because we need the context inside FutureBuilder below
        return FutureBuilder<Map<String, dynamic>>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // don't show button if data isn't loaded yet
              return const SizedBox.shrink();
            }
            final schedules = snapshot.data!['schedules'] as List<Schedule>;
            final subjects = snapshot.data!['subjects'] as List<SubjectModel>;

            return ElevatedButton(
              onPressed: () {
                _showAddScheduleDialog((updatedSchedules) {
                 
                  // setState(() {});
                }, schedules);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add your Schedule"),
            );
          },
        );
      }),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data'),
            );
          }

          final subjects = snapshot.data!['subjects'] as List<SubjectModel>;
          final schedules = snapshot.data!['schedules'] as List<Schedule>;

          final query = searchController.text.toLowerCase();

          final filteredSchedules = schedules.where((schedule) {
            return schedule.title.toLowerCase().contains(query) ||
                schedule.description.toLowerCase().contains(query) ||
                schedule.time.toLowerCase().contains(query);
          }).toList();

          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            "https://trogonmedia.com/assets/images/logo.png",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Trogon Media",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * .9,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: searchController,
                            onChanged: (_) {
                              // Just rebuild widget to refresh filtered schedules
                              // setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: "Search for classes",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 229, 229, 234),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (filteredSchedules.isEmpty)
                          Center(
                            child: Text(
                              "No schedules found",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                        
                        Column(
                          children: [
                            const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Get ready to",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "learn and grow!",
                              style: TextStyle(
                                color: Color.fromARGB(255, 22, 171, 44),
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Subjects",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subjects.length,
                            itemBuilder: (context, index) {
                              final subject = subjects[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ModulesPage(
                                        subjectId: subject.id,
                                        subjectTitle: subject.title,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: subject.image,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          subject.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          subject.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Your schedules",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredSchedules.length,
                            itemBuilder: (context, index) {
                              final schedule = filteredSchedules[index];
                              return GestureDetector(
                                onTap: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(schedule.title),
                                      content: Text(
                                        '${schedule.time}\n\n${schedule.description}',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text("Close"),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 40,
                                          color: Colors.blue[400],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                schedule.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                schedule.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          schedule.time,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 10),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Schedule {
  final String time;
  final String title;
  final String description;

  Schedule({
    required this.time,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {'time': time, 'title': title, 'description': description};

  factory Schedule.fromJson(Map<String, dynamic> m) => Schedule(
        time: m['time'],
        title: m['title'],
        description: m['description'],
      );
}
