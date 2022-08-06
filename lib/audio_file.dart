import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Utils.dart';
import 'notifications/notifications.dart';

class VoiceMessage extends StatefulWidget {
  final String voiceUrl;
  final String voiceName;
   const VoiceMessage({Key? key, required this.voiceUrl, required this.voiceName}) : super(key: key);

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  AudioPlayer advancedAudioPlayer = AudioPlayer();


  // this method to play audio from local
  // update later

  // Future<void> startPlayVoice(fileUrl,fileName)  async {
  //
  //   Directory? appDocDir = await getApplicationDocumentsDirectory();
  //
  //   Directory("${appDocDir.path}/Bego").exists().then((value) {
  //     if (value) {
  //       getVoiceMessagePath("${appDocDir.path}/Bego", fileName, fileUrl);
  //     }else {
  //       Directory("${appDocDir.path}/Bego").create().then((Directory directory){
  //         getVoiceMessagePath("${appDocDir.path}/Bego", fileName, fileUrl);
  //       });
  //     }
  //   });
  // }
  //
  // Future<void> getVoiceMessagePath(String path, fileName, fileUrl) async {
  //
  //   if(isFileDownloaded(path,fileName)){
  //     advancedAudioPlayer.resume();
  //     setState(() {
  //       _isPlaying = true;
  //     });
  //   }else{
  //     final status = await Permission.storage.request();
  //     if(status == PermissionStatus.granted){
  //       buildShowSnackBar(context, "downloading voice message");
  //         Dio().download(fileUrl, "$path/$fileName", onReceiveProgress: (count, total) {
  //           downloadingNotification(total, count, false);
  //         },).whenComplete(() {
  //           downloadingNotification(0, 0, true);
  //         });
  //       }else{
  //       await Permission.storage.request();
  //       }
  //
  //   }
  // }


  @override
  void initState() {
    super.initState();
    initAudioPlayer();
   // initPlayerPath();

    advancedAudioPlayer.setUrl(widget.voiceUrl);

  }

  Future<void> initAudioPlayer() async {

    advancedAudioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    advancedAudioPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    advancedAudioPlayer.onPlayerCompletion.listen((playerState) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });

    });


  }

  // this method to play audio from local
  // update later
  // Future<void> initPlayerPath() async {
  //   Directory? appDocDir = await getApplicationDocumentsDirectory();
  //   Directory("${appDocDir.path}/Bego").exists().then((value) async {
  //     if (value) {
  //       if(isFileDownloaded("${appDocDir.path}/Bego",widget.voiceName)){
  //
  //         advancedAudioPlayer.setUrl("${appDocDir.path}/Bego/${widget.voiceName}",isLocal: true);
  //       }else{
  //         advancedAudioPlayer.setUrl(widget.voiceUrl);
  //
  //
  //       }
  //     }else {
  //      advancedAudioPlayer.setUrl(widget.voiceUrl);
  //
  //     }
  //   });
  // }

  @override
  void dispose() {
    advancedAudioPlayer.dispose();
    advancedAudioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: () async {

              if(_isPlaying == false) {
                // this method to play audio from local
                // update later
                //startPlayVoice(widget.voiceUrl,widget.voiceName);
                advancedAudioPlayer.resume();
                setState(() {
                  _isPlaying = true;
                });
              }else{
                advancedAudioPlayer.pause();
                setState(() {
                  _isPlaying = false;
                });
              }

                }, icon: CircleAvatar(
                child: _isPlaying==false?
                const Icon(Icons.play_arrow):const Icon(Icons.pause))
            ),
            Flexible(
              child: Slider(
                  thumbColor: Colors.black,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey,
                  value: _position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (double value){
                    setState(() {
                      if(_isPlaying) {
                        changeToSecond(value.toInt());
                        value = value;
                      }
                    });
                  }
              ),
            )
          ],
        ),
    Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width*.3,left: 20),
              child: Text(_position.toString().split(".")[0],style: const TextStyle(color: Colors.white)),
            ),
            Text(_duration.toString().split(".")[0],style: const TextStyle(color: Colors.white))
          ],
        ),

      ],
    );
  }
  void changeToSecond(int second){
    Duration newDuration = Duration(seconds: second);
    advancedAudioPlayer.seek(newDuration);

  }
}
