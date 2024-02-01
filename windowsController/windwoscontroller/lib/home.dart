import 'dart:async';
import 'dart:convert';
import 'dart:math';
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

  var swieplist = <List<double>>[];
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
        'wss://testiingdeploy.onrender.com',
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
      debugPrint('connected');
    });

    socket.on("getsid", (data) {
      mysid = data;
      debugPrint(mysid);
    });

    socket.on("getphones", (data) {
      String cleanedString =
          data.replaceAll('[', '').replaceAll(']', '').replaceAll("'", '');
      List<String> resultList = cleanedString.split(',');
      setState(() {
        myphones = resultList.map((element) => element.trim()).toList();
      });
      debugPrint(myphones.toString());
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

    socket.on(
      "message",
      (data) {
        if (data["data"] == "disconnected") {
          setState(() {
            myPhoneSid = "";
            capturing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Phone disconnected")));
        }
      },
    );
  }

  void lock() async {
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

  void sendTap(double x, double y, double height, double width) async {
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

  void selectPhone(int index) async {
    setState(() {
      myPhoneSid = myphones[index];
    });
    socket.emit("createconnection", [
      {"mysid": mysid, "target": myPhoneSid}
    ]);
  }

  List<List<double>> simplifyPoints(
      List<List<double>> points, double tolerance) {
    if (points.length < 3) {
      return points;
    }

    List<List<double>> simplifiedPoints = [];
    simplifiedPoints.add([points.first[0], points.first[1]]);

    _simplify(points, 0, points.length - 1, tolerance, simplifiedPoints);

    simplifiedPoints.add([points.last[0], points.last[1]]);
    return simplifiedPoints;
  }

  void _simplify(List<List<double>> points, int start, int end,
      double tolerance, List<List<double>> simplifiedPoints) {
    double maxDistance = 0;
    int farthestIndex = 0;

    for (int i = start + 1; i < end; i++) {
      double distance =
          perpendicularDistance(points[i], points[start], points[end]);

      if (distance > maxDistance) {
        maxDistance = distance;
        farthestIndex = i;
      }
    }

    if (maxDistance > tolerance) {
      _simplify(points, start, farthestIndex, tolerance, simplifiedPoints);
      simplifiedPoints
          .add([points[farthestIndex][0], points[farthestIndex][1]]);
      _simplify(points, farthestIndex, end, tolerance, simplifiedPoints);
    }
  }

  double perpendicularDistance(
      List<double> point, List<double> lineStart, List<double> lineEnd) {
    double lineLength = distanceBetween(lineStart, lineEnd);
    if (lineLength == 0) {
      return distanceBetween(point, lineStart);
    }

    double t = ((point[0] - lineStart[0]) * (lineEnd[0] - lineStart[0]) +
            (point[1] - lineStart[1]) * (lineEnd[1] - lineStart[1])) /
        (lineLength * lineLength);

    t = t.clamp(0.0, 1.0);

    double x = lineStart[0] + t * (lineEnd[0] - lineStart[0]);
    double y = lineStart[1] + t * (lineEnd[1] - lineStart[1]);

    return distanceBetween(point, [x, y]);
  }

  double distanceBetween(List<double> a, List<double> b) {
    return sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));
  }

  void disconnectUser() async {
    try {
      socket.disconnect();
      socket.dispose();
      socket.destroy();
      mysid = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', "").then((value) =>
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage())));
    } catch (e) {
      throw "error on logout $e";
    }
  }

  @override
  void dispose() {
    if (myPhoneSid.isNotEmpty) {
      stopCapture();
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
                        onLongPressUp: () => print('on long pressed up'),
                        onLongPressDown: (_) => print('on long pressed down'),
                        onLongPressStart: (_) => print('on long press start'),
                        onLongPressCancel: () => print('on long press cancel'),
                        onPanStart: (details) {
                          swieplist = [];
                          var x = double.parse(((details.localPosition.dx /
                                      imageKey.currentContext!.size!.width) *
                                  100)
                              .toStringAsFixed(2));
                          var y = double.parse(((details.localPosition.dy /
                                      imageKey.currentContext!.size!.height) *
                                  100)
                              .toStringAsFixed(2));
                          swieplist.add([x, y]);
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          var x = double.parse(((details.localPosition.dx /
                                      imageKey.currentContext!.size!.width) *
                                  100)
                              .toStringAsFixed(2));
                          var y = double.parse(((details.localPosition.dy /
                                      imageKey.currentContext!.size!.height) *
                                  100)
                              .toStringAsFixed(2));

                          swieplist.add([x, y]);

                          print(details.localPosition);
                        },
                        onPanEnd: (details) {
                          socket.emit("message", {
                            "data": "swipe",
                            "coordinates":
                                simplifyPoints(swieplist, 5).toString(),
                            "target": myPhoneSid,
                            "sid": mysid,
                          });
                        },
                        onTapDown: (details) {
                          double x = details.localPosition.dx;
                          double y = details.localPosition.dy;
                          sendTap(x, y, imageKey.currentContext!.size!.height,
                              imageKey.currentContext!.size!.width);
                          print("x $x y $y");
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
    }

    return Stack(
      children: [
        MyButton(textString: "Log out", function: disconnectUser),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: pageSelector());
  }
}
