import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'exercisedetailspage.dart';
import 'playlist_utils.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<Map<String, dynamic>> exercises = [];
  String selectedDifficulty = "All";
  String selectedCategory = "All";
  String tempSelectedDifficulty = "All";
  String tempSelectedCategory = "All";
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> fetchedExercises = await dbHelper.getAllExercises();
    if (mounted) {
      setState(() {
        exercises = fetchedExercises;
      });
    }
  }

  void _showFilterBottomSheet() {
    setState(() {
      tempSelectedDifficulty = selectedDifficulty;
      tempSelectedCategory = selectedCategory;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Difficulty'),
                    trailing: DropdownButton<String>(
                      value: tempSelectedDifficulty,
                      items: ['All', 'Easy', 'Medium', 'Hard'].map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempSelectedDifficulty = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Category'),
                    trailing: DropdownButton<String>(
                      value: tempSelectedCategory,
                      items: ['All', 'Strength', 'Cardio', 'Core'].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempSelectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            tempSelectedDifficulty = "All";
                            tempSelectedCategory = "All";
                          });
                        },
                        child: Text('Reset Filters'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDifficulty = tempSelectedDifficulty;
                            selectedCategory = tempSelectedCategory;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> getFilteredExercises() {
    return exercises.where((exercise) {
      final matchesSearch = exercise['name']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesDifficulty = selectedDifficulty == "All" || exercise['difficulty'] == selectedDifficulty;
      final matchesCategory = selectedCategory == "All" || exercise['category'] == selectedCategory;
      return matchesSearch && matchesDifficulty && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = getFilteredExercises();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0), 
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ExerciseWidget(exercise: exercise);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseWidget extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseWidget({super.key, required this.exercise});

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  bool isExpanded = false;

  void _showAddToPlaylistForm() async {
    await showAddToPlaylistForm(context, widget.exercise);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.exercise['imageFile'], width: double.infinity, height: 200, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Difficulty: ${widget.exercise['difficulty']}'),
                  Text('Category: ${widget.exercise['category']}'),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_circle, color: Colors.green),
                                onPressed: _showAddToPlaylistForm,
                              ),
                              Text("Add to Playlist", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailsPage(exercise: widget.exercise),
                                    ),
                                  );
                                },
                              ),
                              Text("View Details", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}