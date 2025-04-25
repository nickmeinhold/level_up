import 'package:flutter/material.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:video_player/video_player.dart';

class VideoMessageView extends StatefulWidget {
  const VideoMessageView({
    super.key,
    required this.videoUrl,
    required this.authorId,
    required this.currentUserId,
  });

  final String videoUrl;
  final String authorId;
  final String currentUserId;

  @override
  State<VideoMessageView> createState() => _VideoMessageViewState();
}

class _VideoMessageViewState extends State<VideoMessageView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.authorId == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                locate<ProfileService>().getProfilePicUrlForUser(
                  size: PicSize.small,
                  userId: widget.authorId,
                ),
              ),
            ),
          SizedBox(width: 8.0),
          Flexible(
            child: Center(
              child:
                  _controller.value.isInitialized
                      ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                        ],
                      )
                      : Container(),
            ),
          ),
          SizedBox(width: 8.0),
          if (isMe)
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: NetworkImage(
                locate<ProfileService>().getProfilePicUrl(PicSize.small),
              ),
            ),
        ],
      ),
    );
  }
}
