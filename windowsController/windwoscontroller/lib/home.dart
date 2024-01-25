import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:windwoscontroller/Login.dart';
import 'package:windwoscontroller/phoneSelector.dart';
import 'package:windwoscontroller/widget/buttonWidget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late IO.Socket socket;

  final imageKey = GlobalKey();

  Uint8List? imageString;

  var swieplist = <Offset>[];
  var capturing = false;
  String mysid = "";

  String myPhoneSid = "";
  List<String> myphones = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tryConnecting();
  }

  void tryConnecting() async {
    var _token = await getToken();
    socket = IO.io(
        'ws://192.168.1.13:5000',
        OptionBuilder().setTransports(["websocket"]).setExtraHeaders({
          'Authorization': ['Bearer $_token'],
          'autoConnect': true,
          "hardware": "pc"
        }).build());
    connect(_token);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _token = prefs.getString('token');
    _token ??= "";
    return _token;
  }

  void connect(String key) async {
    socket.onConnect((_) {
      print('connected');
    });

    socket.on("getsid", (data) {
      mysid = data;
      print(mysid);
    });

    socket.on("getphones", (data) {
      String cleanedString =
          data.replaceAll('[', '').replaceAll(']', '').replaceAll("'", '');
      List<String> resultList = cleanedString.split(',');
      setState(() {
        myphones = resultList.map((element) => element.trim()).toList();
      });
      print(myphones);
    });

    socket.onDisconnect(
      (_) {
        if (mysid != "") {
          socket.emit("message", [
            {
              "data": "stop capture",
              "target": myPhoneSid,
              "sid": mysid,
            }
          ]);
        }
        print('disconnected');
        capturing = false;
      },
    );

    socket.on('image_event', (data) {
      if (data != null) {
        print(("recived image"));
        var x = base64Decode(data);
        setState(() {
          imageString = x;
        });
      }
    });
  }

  lock() async {
    socket.emit("message", [
      {
        "data": "lock",
        "target": myPhoneSid,
        "sid": mysid,
      }
    ]);
  }

  void startCapture() {
    if (socket.connected) {
      setState(() {
        capturing = true;
      });

      socket.emit("message", [
        {
          "data": "capture",
          "target": myPhoneSid,
          "sid": mysid,
        }
      ]);
    }
  }

  void stopCapture() {
    if (socket.connected) {
      setState(() {
        capturing = false;
        imageString = null;
      });
      socket.emit("message", [
        {
          "data": "stop capture",
          "target": myPhoneSid,
          "sid": mysid,
        }
      ]);
    }
  }

  void pressedCapture() async {
    if (capturing == false) {
      startCapture();
    } else {
      stopCapture();
    }
  }

  void volumeUpFunction() async {
    if (socket.connected == false) {
      return;
    }

    socket.emit("message", [
      {
        "data": "volumeUp",
        "target": myPhoneSid,
        "sid": mysid,
      }
    ]);
  }

  void volumeDownFunction() async {
    if (socket.connected == false) {
      return;
    }
    socket.emit(
      "message",
      [
        {
          "data": "volumeDown",
          "target": myPhoneSid,
          "sid": mysid,
        }
      ],
    );
  }

  sendTap(double x, double y, double height, double width) async {
    socket.emit("message", [
      {
        "data": "tap",
        "x": ((x / width) * 100).toStringAsFixed(2),
        "y": ((y / height) * 100).toStringAsFixed(2),
        "target": myPhoneSid,
        "sid": mysid,
      }
    ]);
  }

  swipe(Offset offset1, Offset offset2, double height, double width) async {
    // IMPLEMENT new with sendevent~
    // adb shell input swipe x1 y1 x2 y2

    var x1 = (offset1.dx / width) * 100;
    var y1 = (offset1.dy / height) * 100;
    var x2 = (offset2.dx / width) * 100;
    var y2 = (offset2.dy / height) * 100;

    socket.emit("message", [
      {
        "data": "swipe",
        "x1": x1.toStringAsFixed(2),
        "y1": y1.toStringAsFixed(2),
        "x2": x2.toStringAsFixed(2),
        "y2": y2.toStringAsFixed(2),
        "target": myPhoneSid,
        "sid": mysid,
      }
    ]);
  }

  disconnectUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', "").then((value) =>
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage())));
  }

  @override
  void dispose() {
    if (capturing) {
      socket.emit("createconnection", [
        {"mysid": "", "target": myPhoneSid}
      ]);
    }
    try {
      socket.disconnect();
      socket.dispose();
      socket.destroy();
    } catch (e) {
      debugPrint("proleme with disposing of socket $e");
    }
    super.dispose();
  }

  selectPhone(int index) async {
    setState(() {
      myPhoneSid = myphones[index];
    });
    socket.emit("createconnection", [
      {"mysid": mysid, "target": myPhoneSid}
    ]);
    print(index);
  }

  Widget pageSelector() {
    if (myPhoneSid != "") {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: MyButton(
              textString: "Back",
              function: () {
                stopCapture();
                socket.emit("createconnection", [
                  {"mysid": "", "target": myPhoneSid}
                ]);
                setState(() {
                  myPhoneSid = "";
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyButton(
                      textString: capturing ? "Stop capture" : "Start capture",
                      function: pressedCapture,
                    ),
                    MyButton(
                      textString: "Lock",
                      function: lock,
                    ),
                    MyButton(
                      textString: "Volume Up",
                      function: volumeUpFunction,
                    ),
                    MyButton(
                      textString: "Volume Down",
                      function: volumeDownFunction,
                    ),
                  ],
                ),
              ),
              capturing == false || imageString == null
                  ? const SizedBox.shrink()
                  : Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(131, 0, 0, 0),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                      child: GestureDetector(
                        onTapDown: (details) {
                          double x = details.localPosition.dx;
                          double y = details.localPosition.dy;
                          sendTap(x, y, imageKey.currentContext!.size!.height,
                              imageKey.currentContext!.size!.width);
                          print("x $x y $y");
                        },
                        onPanStart: (details) {
                          swieplist = [];
                          swieplist.add(details.localPosition);
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          print('Delta: ${details.localPosition}');
                          swieplist.add(details.localPosition);
                        },
                        onPanEnd: (details) {
                          var p1 = swieplist.first;
                          var p2 = swieplist.last;

                          swipe(p1, p2, imageKey.currentContext!.size!.height,
                              imageKey.currentContext!.size!.width);
                        },
                        child: Image.memory(
                          cacheHeight:
                              MediaQuery.of(context).size.height.toInt(),
                          gaplessPlayback: true,
                          imageString!,
                          key: imageKey,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          const MyButton(textString: "Log out"),
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: PhoneSelectorPage(
              myPhones: myphones,
              callbackFunction: selectPhone,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: pageSelector());
  }
}
