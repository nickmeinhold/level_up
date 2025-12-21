import 'package:flutter/material.dart';
import 'package:level_up_shared/src/profile/profile_service.dart';
import 'package:level_up_shared/src/utils/enums/pic_size.dart';
import 'package:level_up_shared/src/utils/locator.dart';

/// An avatar widget that uses either a Storage path build a CircleAvatar that uses a MemoryImage.
class AsyncAvatar extends StatelessWidget {
  const AsyncAvatar(
    this.picSize, {
    super.key,
    this.backgroundColor = Colors.black,
    this.widgetSize = 50,
  });

  final Color backgroundColor;
  final double widgetSize;
  final PicSize picSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(
          locate<ProfileService>().getProfilePicUrl(picSize),
        ),
      ),
    );
  }
}
