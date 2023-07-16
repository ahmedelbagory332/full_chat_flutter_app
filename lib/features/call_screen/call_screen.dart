import 'package:flutter/material.dart';
import 'package:full_chat_application/features/call_screen/video_call_screen.dart';

import 'audio_call_screen.dart';

class CallScreen extends StatefulWidget {
  final callType;
  const CallScreen(this.callType, {Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.callType == "audio"
        ? const AudioCallScreen()
        : const VideoCallScreen();
  }
}
