import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_app/layout/layout.dart';
import 'package:social_app/layout/layout_controller.dart';
import 'package:social_app/model/message_model.dart';
import 'package:social_app/model/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/shared/components/componets.dart';
import 'package:social_app/shared/constants.dart';
import 'package:social_app/shared/helper/binding.dart';
import 'package:social_app/shared/network/local/cashhelper.dart';
import 'package:social_app/shared/network/remote/diohelper.dart';
import 'package:social_app/shared/styles/thems.dart';

import 'modules/social_login/login.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('on background message');
  print(" message data background " + message.data.toString());

  //showToast(message: "on background message", status: ToastStatus.Success);
}

void main() async {
  // NOTE : to run all thing befor runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: INITIALIZE FIREBASE
  await Firebase.initializeApp();

  await DioHelper.init();
// NOTE : Unique token for device
  token = await FirebaseMessaging.instance.getToken() ?? null;
  print("token messaging -- " + token.toString());

// NOTE : catch notification  with parameter while app is opened  : ForeGroundMessage
  FirebaseMessaging.onMessage.listen((message) {
    print("message data " + message.data.toString());
    SocialLayoutController controller = Get.find<SocialLayoutController>();
    controller.getMyFriend();
    // showToast(message: "on message", status: ToastStatus.Success);
  });

// NOTE : catch notification  with parameter while app is closed and when on press notification
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print("message data opened " + message.data['messageModel'].toString());
    SocialLayoutController controller = Get.find<SocialLayoutController>();
    //controller.getMyFriend();
    // controller.myFriends.where(
    //     (element) => element.uId == message.data['messageModel']['receiverId']);
    // Get.off(ChatDetailsScreen(
    //     socialUserModel: UserModel.fromJson(message.data['messageModel'])));
    //showToast(message: "on message opened", status: ToastStatus.Success);

    MessageModel messageModel =
        MessageModel.fromJson(json.decode(message.data['messageModel']));

    UserModel userModel = controller.myFriends
        .where((element) => element.uId == messageModel.senderId)
        .single;

    Get.to(() => ChatDetailsScreen(socialUserModel: userModel));
  });

// NOTE : catch notification  with parameter while app is in background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await CashHelper.Init();

  Widget widget;

  uId = CashHelper.getData(key: "uId") ?? null;
  print("UId :" + uId.toString());

  var isHasTokenInFireStore = CashHelper.getData(key: "deviceToken") ?? null;

  if (uId != null) {
    widget = SocialLayout();
    // NOTE check if token not set so i set it to used in fcm notification
    if (token != null && isHasTokenInFireStore == null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .update({"deviceToken": token}).then((value) {
        CashHelper.saveData(key: "deviceToken", value: token);
        print("token Saved");
      });
    } else {
      print("token already saved");
    }
  } else {
    widget = LoginScreen();
  }

  //NOTE ----------------------------------

  //NOTE : ADD dependencies

  runApp(MyApp(widget));
}

class MyApp extends StatelessWidget {
  Widget widget;
  MyApp(this.widget);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: lightTheme(),
      themeMode: ThemeMode.light,
      // initialBinding: Binding(),
      debugShowCheckedModeBanner: false,
      home: widget,
    );
  }
}
