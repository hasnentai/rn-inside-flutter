import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel _channel = MethodChannel("main_channel");
  static const String CHANNEL_NAME = "my_channel";
  static const MethodChannel _channel_1 = MethodChannel(CHANNEL_NAME);
  int? counter;
  String? storageData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    _channel_1.setMethodCallHandler((call) async {
      if (call.method == "receiveMessage") {
        String message = call.arguments as String;
        setState(() {
          counter = int.parse(message);
        });
      } else if (call.method == "storeData") {
        String message = call.arguments as String;
        setState(() {
          storageData = message;
        });
        debugPrint(message);
      }
    });
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (counter != null) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Redux Store from RN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '$counter',
                style: const TextStyle(
                  fontSize: 90,
                  color: Colors.black54,
                ),
              ),
            ],
            if (storageData != null) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Local Storage Data from RN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$storageData',
                  style: const TextStyle(),
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _getNewActivity,
              child: const Text("Open React Native View"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getNewActivity,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _getNewActivity() async {
    if (kIsWeb) {
      var res = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => IframeDemo()),
      );

      setState(() {
        counter = res["counter"];
      });
    } else {
      try {
        await _channel.invokeMethod('startRNActivity');
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }
}

class IframeDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyWidget();
  }
}

class MyWidget extends State<IframeDemo> {
  late String _url;
  late IFrameElement _iframeElement;
  int counter = 0;

  @override
  initState() {
    super.initState();
    _url = 'http://localhost:3000';
    _iframeElement = IFrameElement()
      ..src = _url
      ..id = 'iframeElement'
      ..allow = "cross-origin-isolated"
      ..style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iframeElement,
    );

    window.addEventListener('message', (event) {
      var data = (event as MessageEvent).data ?? '-';
      var d = json.decode(data);

      if (d["event-id"] == "redux-data") {
        setState(() {
          var data = d["data"];
          counter = data["counter"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('url is $_url');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {"counter": counter});
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 100,
          ),
          SizedBox(
            height: 300,
            width: 600,
            child: HtmlElementView(
              // key: UniqueKey(),
              viewType: 'iframeElement',
            ),
          ),
        ],
      ),
    );
  }
}
