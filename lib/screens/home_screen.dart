import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../firebase_helper/fireBaseHelper.dart';
import '../provider/my_provider.dart';
import '../serverFunctions/server_functions.dart';
import '../widget/recent_chats.dart';
import '../widget/users.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getDeviceToken().then((value) {
      updateUserToken(Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email, value);
    });
    onTokenRefresh(Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Users"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  FireBaseHelper().signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      'login', (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.logout_sharp))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Users(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                'Recent Chats',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF9899A5)
                    // color: AppColors.textFaded,
                    ),
              ),
            ),
            RecentChats()
          ],
        ),
      ),
    );
  }
}
