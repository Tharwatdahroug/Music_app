import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class Musicplayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTracks;
  final GlobalKey<MusicplayerState> key;
  Musicplayer({this.songInfo, this.changeTracks, this.key}) : super(key: key);
  @override
  MusicplayerState createState() => MusicplayerState();
}

class MusicplayerState extends State<Musicplayer> {
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlayer = false;
  final AudioPlayer player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  @override
  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlayer = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeStatus() {
    setState(() {
      isPlayer = !isPlayer;
    });
    if (isPlayer) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map(
          (e) => e.remainder(60).toString().padLeft(2, '0'),
        )
        .join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('New Playing', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: widget.songInfo.albumArtwork == null
                    ? AssetImage("images/1.jpg")
                    : FileImage(
                        File(widget.songInfo.albumArtwork),
                      ),
                radius: 95,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                child: Text(
                  widget.songInfo.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: Text(
                  widget.songInfo.artist,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Slider(
                inactiveColor: Colors.black12,
                activeColor: Colors.black,
                min: minimumValue,
                max: maximumValue,
                value: currentValue,
                onChanged: (value) {
                  currentValue = value;
                  player.seek(Duration(milliseconds: currentValue.round()));
                },
              ),
              Container(
                transform: Matrix4.translationValues(0, -5, 0),
                margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      endTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.black,
                        size: 55,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTracks(false);
                      },
                    ),
                    GestureDetector(
                      child: Icon(
                        isPlayer
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Colors.black,
                        size: 75,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        changeStatus();
                      },
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.black,
                        size: 55,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTracks(true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
