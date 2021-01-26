import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'package:just_audio/just_audio.dart';
import 'package:music/Music_player.dart';

class Tracks extends StatefulWidget {
  @override
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  final GlobalKey<MusicplayerState> key = GlobalKey<MusicplayerState>();
  int currentIndex = 0;
  @override
  void initState() {
    getTracks();
    super.initState();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTracks(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(
          Icons.music_note,
          color: Colors.black,
        ),
        title: Text('Music App', style: TextStyle(color: Colors.black)),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: songs[index].albumArtwork == null
                      ? AssetImage("images/1.jpg")
                      : FileImage(
                          File(songs[index].albumArtwork),
                        ),
                ),
                title: Text(songs[index].title),
                subtitle: Text(songs[index].artist),
                onTap: () {
                  currentIndex = index;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Musicplayer(
                        songInfo: songs[currentIndex],
                        changeTracks: changeTracks,
                        key: key,
                      ),
                    ),
                  );
                },
              ),
          separatorBuilder: (context, index) => Divider(),
          itemCount: songs.length),
    );
  }
}
