import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'provider/user_provider.dart';

Future<void> showAddToPlaylistForm(BuildContext context, Map<String, dynamic> exercise) async {
  final userId = Provider.of<UserProvider>(context, listen: false).userId;
  if (userId == null) return;

  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> playlists = await dbHelper.getUserPlaylists(userId);

  if (!context.mounted) return;

  if (playlists.isEmpty) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Playlists'),
        content: Text('Please create a playlist first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  if (!context.mounted) return;
  showPlaylistForm(context, playlists, exercise);
}

void showPlaylistForm(BuildContext context, List<Map<String, dynamic>> playlists, Map<String, dynamic> exercise) {
  String? selectedPlaylist;
  bool needsRest = false;
  TextEditingController durationController = TextEditingController();
  TextEditingController restTimeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add to Playlist'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Playlist'),
                    items: playlists.map((playlist) {
                      return DropdownMenuItem<String>(
                        value: playlist['playlistId'].toString(),
                        child: Text(playlist['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedPlaylist = value;
                    },
                    validator: (value) => value == null ? 'Please select a playlist' : null,
                  ),
                  TextFormField(
                    controller: durationController,
                    decoration: InputDecoration(labelText: 'Duration (seconds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a duration';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Add Rest Time'),
                    value: needsRest,
                    onChanged: (value) {
                      setState(() {
                        needsRest = value ?? false;
                      });
                    },
                  ),
                  if (needsRest)
                    TextFormField(
                      controller: restTimeController,
                      decoration: InputDecoration(labelText: 'Rest Time (seconds)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a rest time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    if (selectedPlaylist != null && durationController.text.isNotEmpty) {
                      int playlistId = int.parse(selectedPlaylist!);
                      int duration = int.parse(durationController.text);
                      int restTime = needsRest && restTimeController.text.isNotEmpty
                          ? int.parse(restTimeController.text)
                          : 0;

                      DatabaseHelper dbHelper = DatabaseHelper();
                      await dbHelper.addExerciseToPlaylist(playlistId, exercise['exerciseId'], duration, restTime);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}