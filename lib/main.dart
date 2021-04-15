import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imgpack;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_painter/image_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart' as sqlpack;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getImageFileFromAssets(String path) async {
  WidgetsFlutterBinding.ensureInitialized();
  final byteData = await rootBundle.load('assets/$path');
  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file;
}

void main() async {
  File f1 = await getImageFileFromAssets('amolnew.tiff');
  final animation = imgpack.decodeTiffAnimation(f1.readAsBytesSync());
  animation.frameType = imgpack.FrameType.page;
  f1.writeAsBytesSync(imgpack.encodePng(animation.frames[2]));
  runApp(MaterialApp(  //material App Added
    home: MyApp(
      animation: animation,
      file: f1,
    ),
  ));
}

class DB {
  static var settings = new sqlpack.ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'root',
      password: 'amol2807',
      db: 'docview');

  static getConnect() async {
    var conn = await sqlpack.MySqlConnection.connect(settings);
    return conn;
  }
}

enum AppState {
  free,
  picked,
  cropped,
}

class MyApp extends StatefulWidget {
  final imgpack.Animation animation;
  final File file;

  MyApp({this.animation, this.file});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppState state;
  File imageFile;
  var _imageKey = GlobalKey<ImagePainterState>();
  var _key = GlobalKey<ScaffoldState>();
  ImagePainter imagePainter;
  Offset position ;

  double posx = 100.0;
  double posy = 100.0;

  void onTapDown(BuildContext context, TapDownDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      posx = localOffset.dx;
      posy = localOffset.dy;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    state = AppState.free;
  }

  void saveImage() async {
    print('Amol');
    final image = await _imageKey.currentState.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image);
    var object = await DB.getConnect();
    var results = await object
        .query('insert into screenshots (path) values (?)', ['$fullPath']);
    _key.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            TextButton(
                onPressed: () => OpenFile.open("$fullPath"),
                child: Text("Open", style: TextStyle(color: Colors.blue[200]))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _key,
        appBar: AppBar(
          title: const Text('Flutter Drawing App'),
          actions: [
            IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: saveImage,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            InteractiveViewer(
              panEnabled: false,
              // Set it to false to prevent panning.
              boundaryMargin: EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: ImagePainter.file(
                  widget.file,
                  key: _imageKey,
                  scalable: true,
                ),
                //child: imageFile != null ? Image.file(imageFile) : Container(),
              ),
            ),
            Draggable(
              child: imageFile != null
                  ? Image.file(
                      imageFile,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(
                      height: 0,
                      width: 0,
                    ),
                  feedback:imageFile != null
                      ? Image.file(
                    imageFile,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                      : SizedBox(
                    height: 0,
                    width: 0,
                  ),
                childWhenDragging: SizedBox(height: 0,width: 0,),
            ),

            //canvas
            Padding(
              padding: const EdgeInsets.only(top: 198.0,left: 8,right: 8),
              child: GestureDetector(
                onTapDown: (TapDownDetails details) => onTapDown(context, details),
                child: Stack(
                  children: [
                  Container(
                    width: 410,height: 415,
                    color: Colors.transparent,
                  ),
                  Positioned(
                    child: new Text(''),
                    left: posx,
                    top: posy,
                  ),

                  //co ordinates and alert dialog are not working on same time

                  Container(
                    width: 410,height: 415,
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                  context: context,
                  builder: (ctxt) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: false,
                decoration: new InputDecoration(
                    labelText: 'Add coment', hintText: 'eg. John Smith'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
              );
                      },
                    ),
                  ),
                  
                  ],
                ),
              ),
            ),

            //comp
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            if (state == AppState.free)
              _pickImage();
            else if (state == AppState.picked)
              _cropImage();
            else if (state == AppState.cropped) _clearImage();
          },
          child: _buildButtonIcon(),
        ),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}

