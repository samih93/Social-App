import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_app/layout/layout_controller.dart';
import 'package:social_app/model/storymodel.dart';
import 'package:social_app/modules/addstory/story_controller.dart';
import 'package:social_app/shared/constants.dart';
import "package:story_view/story_view.dart";

class StoryViewScreen extends StatelessWidget {
  String? storyUId;
  StoryViewScreen(this.storyUId);

  final storyController = StoryController();
  var storiesController = Get.put(StoriesController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SocialLayoutController>(
        init: Get.find<SocialLayoutController>(),
        builder: (socialLayoutController) {
          List<StoryModel> stories = [];
          socialLayoutController.storiesMap[storyUId]!.forEach((element) {
            stories.add(StoryModel.formJson(element));
          });
          return Scaffold(
            body: _DisplayStories(stories),
          );
        });
  }

  _DisplayStories(List<StoryModel> stories) {
    List<StoryItem> storyItems = [];

    stories.forEach((element) {
      storyItems.add(StoryItem.inlineImage(
        imageFit: BoxFit.contain,
        url: element.image.toString(),
        controller: storyController,
        caption: Text(
          element.caption.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.black54,
            fontSize: 17,
          ),
        ),
      ));
      storiesController.storytime.value = stories[0].storyDate.toString();
    });

    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        StoryView(
          controller: storyController,
          storyItems: storyItems,

          onStoryShow: (storyitem) {
            print("Showing a story");
            int pos = storyItems.indexOf(storyitem);
            if (pos > 0) {
              storiesController.onchangeStorytime(stories[pos].storyDate);
            }
          },
          onComplete: () {
            print("Completed a cycle");
            Get.back();
          },
          progressPosition: ProgressPosition.top,
          repeat: false,
          //  inline: true,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 25),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/default profile.png')),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stories[0].storyName.toString(),
                    style: TextStyle(
                      height: 1.4,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${convertToAgo(DateTime.parse(storiesController.storytime.value.toString()))} ago',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
