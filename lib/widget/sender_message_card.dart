import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../audio_file.dart';

class SenderMessageCard extends StatefulWidget {
    const SenderMessageCard( this.fileName,this.msgType,this.msg, this.time, {Key? key}) : super(key: key);

   final String msg;
   final String time;
    final String msgType;
    final String fileName;

  @override
  State<SenderMessageCard> createState() => _SenderMessageCardState();
}

class _SenderMessageCardState extends State<SenderMessageCard> {
    late VideoPlayerController _videoPlayerController;
    ChewieController? _chewieController;
    int? bufferDelay;
   Widget messageBuilder(context){
     Widget body = Container();
     if(widget.msgType == "image"){
       body = Padding(
         padding: const EdgeInsets.only(top: 5,bottom: 5),
         child:SizedBox(
           width: 250,
           height: 250,
           child: InkWell(
             onTap: (){
               showDialog(
                   context: context,
                   builder: (context) {
                     return  Center(
                       child: InteractiveViewer(
                         panEnabled: false,
                         boundaryMargin: const EdgeInsets.all(50),
                         minScale: 0.5,
                         maxScale: 2,
                         child: FadeInImage.assetNetwork(
                           placeholder: 'images/Fading lines.gif',
                           image: widget.msg,
                         ),
                       ),
                     );
                   }
               );
             },
             child: FadeInImage.assetNetwork(
               placeholder: 'images/Fading lines.gif',
               image: widget.msg,
             ),
           ),
         ),
       );
     }
     else if(widget.msgType == "text"){
       body = Padding(
         padding: const EdgeInsets.only(
             left: 10, right: 20, top: 5,bottom: 5),
         child: SelectableText(
           widget.msg,
           style: const TextStyle(
               fontSize: 16,
               color: Colors.white
           ),
         ),
       );
     }
     else if(widget.msgType == "video"){
       body = SizedBox(
         height: MediaQuery.of(context).size.height *.3,
         width: MediaQuery.of(context).size.width *.5,
         child: Padding(
           padding: const EdgeInsets.all(2.0),
           child: Column(
             children: <Widget>[
               Expanded(
                 child: _chewieController != null && _chewieController!
                     .videoPlayerController.value.isInitialized
                     ? Chewie(controller: _chewieController!,)
                     : Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: const [
                     CircularProgressIndicator(color: Colors.black),
                     SizedBox(height: 20),
                     Text('Loading Video'),
                   ],
                 ),
               ),
             ],
           ),
         ),
       );
     }
     else if(widget.msgType == "document"){
       body =  body = Padding(
         padding: const EdgeInsets.only(
             left: 10, right: 20, top: 5,bottom: 5),
         child: SelectableText(
           widget.fileName,
           style: const TextStyle(
               fontSize: 16,
               color: Colors.white
           ),
         ),
       );
     }
     else if(widget.msgType == "audio"){
       body =  body = Padding(
         padding: const EdgeInsets.only(
             left: 10, right: 20, top: 5,bottom: 5),
         child: SelectableText(
           widget.fileName,
           style: const TextStyle(
               fontSize: 16,
               color: Colors.white
           ),
         ),
       );
     }
     else if(widget.msgType == "voice message"){
       body  = SizedBox(
         width: MediaQuery.of(context).size.width*.7 ,
         child: Padding(
           padding: const EdgeInsets.only(
               left: 10, right: 20, top: 5,bottom: 5),
             child: VoiceMessage(voiceUrl:widget.msg,voiceName:widget.fileName)
         ),
       );
     }
     return body;
   }
    @override
    void initState() {
      super.initState();
      initializePlayer(widget.msg);

    }


    @override
    void dispose() {
       _videoPlayerController.dispose();
       _chewieController?.dispose();

      super.dispose();
    }




    Future<void> initializePlayer(videoUrl) async {
      _videoPlayerController= VideoPlayerController.network(videoUrl);
      await Future.wait([_videoPlayerController.initialize(),]);
      _createChewieController();
      setState(() {});
    }

    void _createChewieController() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: true,
        progressIndicatorDelay:
        bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
        hideControlsTimer: const Duration(seconds: 1),
      );
    }



    @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.blue,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                messageBuilder(context),

                Padding(
                 padding: const EdgeInsets.only(left: 8,right: 8,bottom: 8),
                 child: Text(widget.time,
                  style:
                  const TextStyle(fontSize: 13, color: Colors.white)),
            )
          ]),
        ));
  }



}

