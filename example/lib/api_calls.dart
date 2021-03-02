import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

/*
  NOTE: 
  This app is for example purposes only.  In a production app you do *not*
  want to store authorization headers or API keys on the client device, much less in plain text.  
  Ideally you will proxy the requests to a server, which stores the API key and acts
   as a middleman to the Songclip API.
*/
final authHeader = 'YOUR_HEADER_HERE'; //change this to your auth header value
final apikey = 'YOUR APIKEY_HERE'; //change to your API key

Future<List<Clip>> fetchClips() async {
  List<Clip> clips = [];

  final response = await http.get(
    "https://api.songclip.com/songclips/?q=love&shuffle=true&page=1&limit=20&minLength=10&maxLength=300",
    headers: {
      HttpHeaders.authorizationHeader: authHeader,
      "apikey": apikey,
    },
  );
  final responseJson = jsonDecode(response.body);
  clips = responseJson['data']['songclips']
      .map<Clip>((item) => Clip.fromJson(item))
      .toList();
  return clips;
}

Future<Response> playEvent(clipId) {
  return http.post(
    'https://api.songclip.com/songclips/${clipId}/events/play',
    headers: {
      HttpHeaders.authorizationHeader: authHeader,
      "apikey": apikey,
    },
    body: jsonEncode(<String, Object>{
      'context': {
        'sourcePlatform': 'iOS',
        'sessionId': 'U7BMARUXDWNY',
        'uniqueId': 'd35ef6f6ee1b',
      }
    }),
  );
}

Future<http.Response> shareEvent(clipId) async {
  final response = await http.post(
    'https://api.songclip.com/songclips/${clipId}/events/share',
    headers: {
      HttpHeaders.authorizationHeader: authHeader,
      "apikey": apikey,
    },
    body: jsonEncode(<String, Object>{
      'context': {
        'sourcePlatform': 'iOS',
        'sessionId': 'U7BMARUXDWNY',
        'uniqueId': 'd35ef6f6ee1b',
      }
    }),
  );
  Fluttertoast.showToast(
      msg: "Share event recorded",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
  return response;
}

/*
  Utility class for dealing with song clips
  Note the 'factory' constructor (a Dart feature) for building
  a class instance from a json object
*/
class Clip {
  final String audioUrl;
  final String id;
  final String title;
  final String coverUrl;

  Clip({this.audioUrl, this.id, this.title, this.coverUrl});

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
        audioUrl: json['audioUrl'],
        id: json['id'],
        title: json['title'],
        coverUrl: json['coverUrl']);
  }
}
