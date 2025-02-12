import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'database_helper.dart';
import 'provider/user_provider.dart';
import 'viewplaylistpage.dart'; 

Future<void> viewPlaylists() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> playlists = await dbHelper.getAllPlaylists();
  print("All Playlists:");
  for (var playlist in playlists) {
    print(playlist);
  }
}

Future<void> viewPlaylistExercise() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> playlists = await dbHelper.getAllPlaylistExercise();
  print("All Playlist Exercise:");
  for (var playlist in playlists) {
    print(playlist);
  }
}

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<Map<String, dynamic>> playlists = [];

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
    viewPlaylists();
    viewPlaylistExercise();
  }

  Future<void> fetchPlaylists() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> fetchedPlaylists = await dbHelper.getUserPlaylists(userId);
      List<Map<String, dynamic>> updatedPlaylists = [];
      for (var playlist in fetchedPlaylists) {
        int exerciseCount = await dbHelper.getExerciseCountForPlaylist(playlist['playlistId']);
        Map<String, dynamic> updatedPlaylist = Map<String, dynamic>.from(playlist);
        updatedPlaylist['exerciseCount'] = exerciseCount;
        updatedPlaylists.add(updatedPlaylist);
      }
      setState(() {
        playlists = updatedPlaylists;
      });
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deletePlaylist(playlistId);
    fetchPlaylists();
  }

  void _showAddPlaylistForm() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Playlist'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Playlist Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = Provider.of<UserProvider>(context, listen: false).userId;
                if (userId != null && nameController.text.isNotEmpty) {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  await dbHelper.insertPlaylist({
                    'userId': userId,
                    'name': nameController.text,
                  });
                  fetchPlaylists();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int playlistId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Playlist'),
          content: Text('Are you sure you want to delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await deletePlaylist(playlistId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: playlists.isEmpty
            ? Center(
                child: Text(
                  'You have no playlists',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        return PlaylistCard(
                          title: playlists[index]['name'],
                          exercises: playlists[index]['exerciseCount'] ?? 0,
                          playlistId: playlists[index]['playlistId'], // Pass the playlistId
                          onDelete: () => _showDeleteConfirmationDialog(playlists[index]['playlistId']),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaylistForm,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String title;
  final int exercises;
  final int playlistId; 
  final VoidCallback onDelete; 

  const PlaylistCard({super.key, required this.title, required this.exercises, required this.playlistId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "$exercises Exercises",
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewPlaylistPage(
                          playlistId: playlistId,
                          playlistName: title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.eye, color: Colors.green),
                ),
                IconButton(
                  onPressed: onDelete, // Call onDelete callback
                  icon: const Icon(LucideIcons.trash, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}