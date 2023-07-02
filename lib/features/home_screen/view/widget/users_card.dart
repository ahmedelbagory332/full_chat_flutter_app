import 'package:flutter/material.dart';

class UsersCard extends StatelessWidget {
  final String userName;

  const UsersCard(this.userName, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children:   [
        const CircleAvatar(
          backgroundColor: Colors.black12,
          backgroundImage: AssetImage("images/avatar.png"),
          radius: 25.0,//radius of the circle avatar
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              userName,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
