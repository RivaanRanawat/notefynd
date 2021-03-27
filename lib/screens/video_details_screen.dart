import "package:flutter/material.dart";
import 'package:notefynd/universal_variables.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends StatefulWidget {
  final thumbnail;
  final title;
  final likeCount;
  final channelAvatar;
  final channelName;
  final video;

  VideoDetailScreen(
      {@required this.thumbnail,
      @required this.title,
      @required this.likeCount,
      @required this.channelAvatar,
      @required this.channelName,
      @required this.video});
  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController _videoPlayerController;
  bool startedPlaying = false;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.video);
    _videoPlayerController.addListener(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _layouts = [
      _videoInfo(),
      _channelInfo(),
      _moreInfo(),
    ];

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      _layouts.clear();
    }

    return Scaffold(
        backgroundColor: UniversalVariables().secondaryColor,
        body: Column(
          children: <Widget>[
            _buildVideoPlayer(context),
            Expanded(
              child: ListView(
                children: _layouts,
              ),
            )
          ],
        ));
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? 200.0
          : MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //       image: NetworkImage(widget.thumbnail), fit: BoxFit.cover),
      // ),
      child: FutureBuilder<bool>(
        future: started(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == true) {
            return AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            );
          } else {
            return const Text('waiting for video to load');
          }
        },
      ),
    );
  }

  Widget _videoInfo() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildButtonColumn(Icons.thumb_up_alt_outlined, widget.likeCount),
              _buildButtonColumn(Icons.share, "Share"),
              _buildButtonColumn(Icons.cloud_download, "Download"),
              _buildButtonColumn(Icons.playlist_add, "Save"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildButtonColumn(IconData icon, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _channelInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.channelAvatar),
              ),
              title: Text(
                widget.channelName,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              // subtitle: Text("1m subscribers"),
            ),
          ),
          // TextButton.icon(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.play_circle_filled,
          //       color: Colors.red,
          //     ),
          //     label: Text(
          //       "JOIN",
          //       style: TextStyle(color: Colors.red),
          //     ))
        ],
      ),
    );
  }

  Widget _moreInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: Text(
            "Up next",
            style: TextStyle(color: Colors.white),
          )),
          Text(
            "Autoplay",
            style: TextStyle(color: Colors.white),
          ),
          Switch(
            onChanged: (c) {},
            value: true,
          ),
        ],
      ),
    );
  }
}
