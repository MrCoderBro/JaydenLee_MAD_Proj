import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class PlayPlaylistPage extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final String playlistName;

  const PlayPlaylistPage({super.key, required this.exercises, required this.playlistName});

  @override
  State<PlayPlaylistPage> createState() => _PlayPlaylistPageState();
}

class _PlayPlaylistPageState extends State<PlayPlaylistPage> {
  int currentExerciseIndex = 0;
  Timer? timer;
  bool isPlaying = false;
  int remainingTime = 0;

  @override
  void initState() {
    super.initState();
    startExercise();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startExercise() {
    timer?.cancel(); 
    setState(() {
      remainingTime = widget.exercises[currentExerciseIndex]['duration'];
      isPlaying = true;
    });
    resumeTimer();
  }

  void resumeTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          moveToNextExercise();
        }
      });
    });
  }

  void moveToNextExercise() {
    if (currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
      startExercise();
    } else {
      setState(() {
        isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playlist completed!')),
      );
      Navigator.pop(context); 
    }
  }

  void moveToPreviousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
      });
      startExercise();
    }
  }

  void pauseExercise() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void resumeExercise() {
    setState(() {
      isPlaying = true;
    });
    resumeTimer();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[currentExerciseIndex];
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentExercise['imageFile'] != null)
              Image.asset(currentExercise['imageFile'], width: 200, height: 200, fit: BoxFit.cover)
            else
              Icon(Icons.image_not_supported, size: 200),
            SizedBox(height: 20),
            Text(
              currentExercise['name'] ?? 'Unknown Exercise',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Remaining Time: $remainingTime seconds',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 36),
                  onPressed: moveToPreviousExercise,
                ),
                SizedBox(width: 20),
                if (isPlaying)
                  IconButton(
                    icon: Icon(Icons.pause, size: 36),
                    onPressed: pauseExercise,
                  )
                else
                  IconButton(
                    icon: Icon(Icons.play_arrow, size: 36),
                    onPressed: resumeExercise,
                  ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 36),
                  onPressed: moveToNextExercise,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}