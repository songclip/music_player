import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import './api_calls.dart';

import 'player_widget.dart';

typedef void OnError(Exception exception);

void main() {
  runApp(MaterialApp(home: ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;
  List<Clip> songClips = [];

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }
  }

  Widget songclipApi() {
    return _Tab(children: [
      _Btn(
          txt: 'Click for API search',
          onPressed: () async {
            var retVal = await fetchClips();
            setState(() {
              songClips = retVal;
            });
          }),
      Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0)),
      SongListing(children: songClips)
    ]);
  }

  Widget about() {
    return Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
              Color(0xFF662483),
              Colors.red,
            ])),
        child: Center(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 40)),
              Text("Sample app courtesy of songclip.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
              SizedBox(
                child: Image.asset('assets/songclip_logo_white.png'),
                height: 175,
                width: 175,
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Duration>.value(
            initialData: Duration(),
            value: advancedPlayer.onAudioPositionChanged),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Songclip'),
                Tab(text: 'About'),
              ],
            ),
            title: Text('Songclip API Sampler'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                    Color(0xFF662483),
                    Colors.red,
                  ])),
            ),
          ),
          body: TabBarView(
            children: [
              songclipApi(),
              about(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final List<Widget> children;

  const _Tab({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
              Colors.grey,
              Colors.white,
            ])),
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(6.0),
        child: SingleChildScrollView(
          child: Column(
            children: children
                .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class SongListing extends StatelessWidget {
  final List<Clip> children;

  const SongListing({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(6.0),
        child: SingleChildScrollView(
          child: Column(
            children: children.map((w) {
              //Container(child: w, padding: EdgeInsets.all(6.0))
              return Column(children: [
                SizedBox(child: Image.network(w.coverUrl), height: 175),
                PlayerWidget(key: ObjectKey(w.id), url: w.audioUrl, id: w.id),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _Btn({Key key, this.txt, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      buttonColor: Colors.white,
      minWidth: 48.0,
      child: FlatButton(
        //child: Text(txt),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF662483), Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            //borderRadius: BorderRadius.circular(30.0),
            //color: Colors.red,
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              txt,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
