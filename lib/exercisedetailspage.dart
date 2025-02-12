import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/playlist_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailsPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    String youtubeLink = widget.exercise['youtubeLink'];
    _videoId = YoutubePlayer.convertUrlToId(youtubeLink);

    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          widget.exercise['name'],
          style: GoogleFonts.robotoSlab(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      onReady: () {
                        _controller!.addListener(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.exercise['name'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Difficulty: ${widget.exercise['difficulty']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${widget.exercise['category']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.exercise['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showAddToPlaylistForm(context, widget.exercise);
              },
              child: Text('Add to Playlist'),
            ),
          ),
        ],
      ),
    );
  }
}
