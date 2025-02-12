// ...existing code...
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'playplaylistpage.dart';

class ViewPlaylistPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const ViewPlaylistPage({super.key, required this.playlistId, required this.playlistName});

  @override
  State<ViewPlaylistPage> createState() => _ViewPlaylistPageState();
}

class _ViewPlaylistPageState extends State<ViewPlaylistPage> {
  List<Map<String, dynamic>> exercises = [];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> fetchedExercises = await dbHelper.getPlaylistExercises(widget.playlistId);
    setState(() {
      exercises = fetchedExercises;
    });
  }

  Future<void> deleteExercise(int playlistExerciseId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteExerciseFromPlaylist(playlistExerciseId);
    fetchExercises();
  }

  void _playPlaylist() {
    if (exercises.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayPlaylistPage(
            exercises: exercises,
            playlistName: widget.playlistName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          widget.playlistName,
          style: GoogleFonts.robotoSlab(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    leading: exercise['imageFile'] != null
                        ? Image.asset(exercise['imageFile'], width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported, size: 50),
                    title: Text(exercise['name'] ?? 'Unknown Exercise'),
                    subtitle: Text('${exercise['difficulty'] ?? 'Unknown Difficulty'} - ${exercise['category'] ?? 'Unknown Category'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Duration: ${exercise['duration']} seconds'),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await deleteExercise(exercise['playlistExerciseId']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: exercises.isNotEmpty ? _playPlaylist : null,
                child: Text('Play Playlist'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}