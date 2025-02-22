import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../models/Song.dart';

class MusicPlayerScreen extends StatefulWidget {

  final Song song;

  const MusicPlayerScreen({super.key, required this.song});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {

  final player = AudioPlayer();
  bool isPlaying =false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {

    super.initState();
    super.initState();

    // Listen to player state changes

    player.onPlayerStateChanged.listen((state) {
      setState(() {

        isPlaying =state ==PlayerState.playing;
      });
    });

    // Listen to audio position changes
    player.onPositionChanged.listen((position) {
      setState(() {
        currentPosition =position;
      });
    });


    // Listen to total duration of audio file

    player.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration =duration;
      });
    });
  }


  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<void> playPauseAudio() async {
    if (isPlaying) {
      await player.pause();
    }else {
      await player.play(UrlSource(widget.song.song_path));
    }
  }


  String formatTime(Duration duration) {

    String minutes =duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.song.image_path,
              height: 200,
              width: 200,
              errorBuilder: (context,error,stackTrace) =>
                  Icon(Icons.music_note,size: 100),
            ),
            SizedBox(height:20),
            Text(
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                widget.song.name
            ),
            SizedBox(height:20),
            Slider(
              min:0,
              max: totalDuration.inSeconds.toDouble(),
              value: currentPosition.inSeconds.toDouble(),
              onChanged: (value) async {
                await player.seek(Duration(seconds: value.toInt()));
              },
            ),
            // Text(widget.song.song_path)

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(currentPosition)),
                  Text(formatTime(totalDuration)),
                ],
              ),
            ),
            SizedBox(height: 20),

            TextButton(
              onPressed: playPauseAudio,
              child: Text(isPlaying ? "Pause" : "Play"),

            ),
          ],
        ),
      ),
    );
  }
}