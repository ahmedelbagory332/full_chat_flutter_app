// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:full_chat_application/Utils.dart';
import 'package:full_chat_application/notifications/notifications.dart';
import 'package:full_chat_application/serverFunctions/server_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../provider/my_provider.dart';
import '../firebase_helper/fireBaseHelper.dart';

class MessagesCompose extends StatefulWidget {
   const MessagesCompose({Key? key}) : super(key: key);

  @override
  State<MessagesCompose> createState() => _MessagesComposeState();
}

class _MessagesComposeState extends State<MessagesCompose> with WidgetsBindingObserver{
  final TextEditingController _textController = TextEditingController();
  bool isRecorderReady = false;
  bool sendChatButton = false;
  bool startVoiceMessage = false;
  final ImagePicker _picker = ImagePicker();
  final recorder = FlutterSoundRecorder();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
     cancelRecord();
    super.dispose();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
        setState(() {
          cancelRecord();
        });
        break;
      case AppLifecycleState.inactive:
        setState(() {
          cancelRecord();
        });
        break;
      case AppLifecycleState.detached:
        setState(() {
          cancelRecord();
        });
        break;
      case AppLifecycleState.resumed:
        break;
    }    super.didChangeAppLifecycleState(state);
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        startVoiceMessage==true?
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
                builder: (context, snapshot) {
                   final duration  = snapshot.hasData
                       ? snapshot.data!.duration
                       : Duration.zero;
                   String twoDigits(int n) => n.toString().padLeft(2,'0');
                   final twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
                   final twoDigitsSecond = twoDigits(duration.inSeconds.remainder(60));
                   return SizedBox(
                       width: MediaQuery.of(context).size.width - 55,
                       child:Card(
                         color: Colors.blueAccent,
                         margin: const EdgeInsets.only(
                             left: 5, right: 5, bottom: 8),
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(25)),
                         child: Center(
                             child: Padding(
                               padding:
                               const EdgeInsets.all(10),
                               child: Text("$twoDigitsMinutes:$twoDigitsSecond"
                                 ,style:const TextStyle(
                                     fontWeight: FontWeight.bold,
                                     color: Colors.white,
                                     fontSize: 15
                                 ) ,),
                             )
                         ),
                       )

                   );
                },
            )
            :
        SizedBox(
            width: MediaQuery.of(context).size.width - 55,
            child: Card(
              color: Colors.blueAccent,
              margin: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: TextField(
                  style: const TextStyle(color: Colors.white,),
                  controller: _textController,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      FireBaseHelper().updateUserStatus("typing....",Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
                      setState(() {
                        sendChatButton = true;
                      });
                    } else {
                      FireBaseHelper().updateUserStatus("Online",Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
                      setState(() {
                        sendChatButton = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type your message",
                    hintStyle: const TextStyle(color: Colors.white,),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                        onPressed: () async{
                          final status = await Permission.storage.request();
                          if(status == PermissionStatus.granted) {
                            FilePickerResult? result = await FilePicker.platform.pickFiles();
                            UploadTask uploadTask = FireBaseHelper().getRefrenceFromStorage(
                                result, "", context);
                            if (lookupMimeType(result!.files.single.path.toString())!.contains(
                                "video")) {
                              uploadFile("", "video", uploadTask, context);
                            } else if (lookupMimeType(result.files.single.path.toString())!.contains(
                                "application")) {
                              uploadFile(result.files.single.name, "document", uploadTask, context);
                            } else if (lookupMimeType(result.files.single.path.toString())!.contains(
                                "image")) {
                              uploadFile("", "image", uploadTask, context);
                            } else if (lookupMimeType(result.files.single.path.toString())!.contains(
                                "audio")) {
                              uploadFile(result.files.single.name, "audio", uploadTask, context);
                            } else {
                              buildShowSnackBar(context, "unsupported format");
                            }
                          }else{
                            await Permission.storage.request();
                          }

                            },
                            icon: const Icon(Icons.attach_file,color: Colors.white,)),
                        IconButton(
                            onPressed: ()  async {
                              final status = await Permission.storage.request();
                              if(status == PermissionStatus.granted) {
                                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                                UploadTask uploadTask = FireBaseHelper().getRefrenceFromStorage(
                                    photo, "", context);
                                uploadFile("", "image", uploadTask, context);
                              }else{
                                await Permission.storage.request();
                              }

                            },
                            icon: const Icon(Icons.camera,color: Colors.white,)
                        )
                      ],
                    ),
                    contentPadding: const EdgeInsets.all(5),
                  )),
            )),
        Padding(
          padding:
          const EdgeInsets.only(bottom: 8.0, right: 2),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blueAccent,
            child:IconButton(
                onPressed: () async {
                  if (sendChatButton) {
                    //txt message
                    FireBaseHelper().sendMessage(
                        chatId : Provider.of<MyProvider>(context,listen: false).getChatId(context),
                        senderId : Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid,
                        receiverId : Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
                        msgTime : FieldValue.serverTimestamp(),
                        msgType : "text",
                        message : _textController.text.toString(),
                        fileName: ""
                    );

                    FireBaseHelper().updateLastMessage(
                        chatId : Provider.of<MyProvider>(context,listen: false).getChatId(context),
                        senderId : Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid,
                        receiverId : Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
                        receiverUsername : Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
                        msgTime : FieldValue.serverTimestamp(),
                        msgType : "text",
                        message : _textController.text.toString(),
                        context: context
                    );
                    notifyUser(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName,
                        _textController.text.toString(),
                        Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
                        Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email);
                    _textController.clear();
                    setState(() {
                      sendChatButton = false;
                    });
                    FireBaseHelper().updateUserStatus("Online",Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);

                  }
                  else{
                    final status = await Permission.microphone.request();
                    if(status ==PermissionStatus.granted) {
                      await initRecording();
                      if(recorder.isRecording){
                        await stop();
                        setState(() {
                          startVoiceMessage = false;
                        });
                      }else{
                        await record();
                        setState(() {
                          startVoiceMessage = true;
                        });
                      }
                    }else{
                      buildShowSnackBar(context, "You must enable record permission");
                    }
                    // voice message

                  }
                },
                icon: Icon(
                  sendChatButton ? Icons.send :startVoiceMessage==true?Icons.stop:Icons.mic,
                  color: Colors.white,
                )),


          ),
        ),
      ],
    );
  }

  Future<void> initRecording() async {
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void uploadFile(String fileName,String fileType,UploadTask uploadTask, BuildContext context) {
    uploadTask.snapshotEvents.listen((event) {
      uploadingNotification(
          fileType,
          Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
          event.totalBytes,
          event.bytesTransferred,
          true
      );
    });
    uploadTask.whenComplete(() => {

      uploadingNotification(
          fileType,
          Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],0, 0, false),

    notifyUser(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName,
        "send to you $fileType",
    Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
    Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email),

      uploadTask.then((fileUrl) {
        fileUrl.ref.getDownloadURL().then((value) {
          FireBaseHelper().sendMessage(
              chatId : Provider.of<MyProvider>(context,listen: false).getChatId(context),
              senderId : Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid,
              receiverId : Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
              msgTime : FieldValue.serverTimestamp(),
              msgType : fileType,
              message : value,
              fileName: (fileType =="document")||(fileType =="audio")||(fileType =="voice message")? fileName:""
          );

          FireBaseHelper().updateLastMessage(
              chatId : Provider.of<MyProvider>(context,listen: false).getChatId(context),
              senderId : Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid,
              receiverId : Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
              receiverUsername : Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
              msgTime : FieldValue.serverTimestamp(),
              msgType : fileType,
              message : value,
              context: context
          );
        });
      })
    });
  }


  Future record() async{
    if(!isRecorderReady) return;
    await recorder.startRecorder(toFile: "voice.mp4");
  }

  Future stop() async{
    String voiceMessageName = "${DateTime.now().toString()}.mp4";
    if(!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
      UploadTask uploadTask = FireBaseHelper().getRefrenceFromStorage(audioFile,voiceMessageName, context);
       uploadFile(voiceMessageName,"voice message",uploadTask, context);
  }

  void cancelRecord() {
    isRecorderReady = false;
    sendChatButton = false;
    startVoiceMessage = false;
    recorder.closeRecorder();
  }

}