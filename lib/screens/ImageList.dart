import 'package:denkuan_sebari/widgets/image_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ImageList extends StatefulWidget {
  final List<Map<String, dynamic>> fileData;

  const ImageList({Key? key, required this.fileData}) : super(key: key);

  @override
  State<ImageList> createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  List<Map<String, dynamic>> fileData = [];
  late ScrollController gridViewController;

  bool atTheTop = true;

  @override
  void initState() {
    gridViewController = ScrollController();
    fileData = widget.fileData;
    gridViewController.addListener(() {
      if (gridViewController.position.pixels < 175) {
        setState(() {
          atTheTop = true;
        });
      } else {
        setState(() {
          atTheTop = false;
        });
      }
    });
    subscribeToServer();
    super.initState();
  }

  @override
  void dispose() {
    gridViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepPurpleAccent.withOpacity(.3),
      appBar: AppBar(
        elevation: 0.0,
        // backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Denkuan Sebari'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: GridView.builder(
          controller: gridViewController,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 1.w,
              mainAxisSpacing: 1.h,
              mainAxisExtent: 150.h),
          itemCount: fileData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> image = fileData[index];
            return ImageBuilder(
              imagePath: image['imagePath'],
              isRemote: image['isRemote'],
            );
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: !atTheTop,
        child: FloatingActionButton(
          // backgroundColor: Colors.deepPurple,
          child: Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: const RotatedBox(
                quarterTurns: 1, child: Icon(Icons.arrow_back_ios)),
          ),
          onPressed: () {
            gridViewController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn);
          },
        ),
      ),
    );
  }

  void subscribeToServer() async {
    print('subscribing');
    try {
      IO.Socket socket = IO.io('http://192.168.45.109:3000', {
        'autoConnect': true,
        'transports': ['websocket']
      });
      socket.connect();
      socket.onConnect((_) {
        print('connected to the server');
      });
      socket.on('newPhoto', (data) {
        setState(() {
          fileData.insert(0, {'imagePath': data, 'isRemote': true});
        });
      });

      socket.onDisconnect((_) => print('disconnect'));
    } catch (e) {
      print(e);
    }
  }
}
