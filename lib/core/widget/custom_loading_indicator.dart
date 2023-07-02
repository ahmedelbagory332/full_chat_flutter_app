import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      // check device type then apply default platform progress
      child: Platform.isAndroid ? const CircularProgressIndicator()
          : const CupertinoActivityIndicator()
    );
  }
}
