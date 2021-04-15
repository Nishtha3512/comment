import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _commentController = TextEditingController();

  int counter = 1;

  var map = Map();

  /* map.update(2,(v){
    return 'TWO';
    
  });
    print(map);
  
  map.remove(2);*/ //2 is the key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                  child: Container(
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //  Text('Choose a Date And Time'),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(color: Colors.yellow)),
                            child: Center(
                              child: TextFormField(
                                  maxLines: 4,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.text,
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(),
                                      hintText: 'Add a Comment',
                                      isDense: true, // Added this
                                      contentPadding: EdgeInsets.all(10.0),
                                      //  labelText: 'Ad',
                                      fillColor: Colors.white,
                                      focusColor: Colors.teal[200],
                                      border: InputBorder.none)),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _commentController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                        // foregroundColor: HexColor('FF0000'),
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )),
                                  )),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      map.addAll(
                                          {counter: _commentController.text});

                                      //print(map);
                                      //print(map.values);
                                      _commentController.clear();
                                      counter++;
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                        // foregroundColor: HexColor('FF0000'),
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Text(
            'abc',
            style: TextStyle(color: Colors.white),
          ),
        ),
      )),
    );
  }
}
