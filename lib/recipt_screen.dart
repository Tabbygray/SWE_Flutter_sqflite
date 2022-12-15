import "package:flutter/material.dart";
import "dart:async";
import "dart:ui";

class ReciptScreen extends StatelessWidget {
  final String recipeName;
  final String reciptData;
  final String recipeTags;

  const ReciptScreen(this.recipeName, this.reciptData, this.recipeTags);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: Text('$recipeName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // 레시피 내용 들어가는 컨테이너
                color: Colors.white,
                child: Text('레시피 : $reciptData')),
            Container(
              color: Colors.white,
              child: Text('태그 : $recipeTags'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('타이머'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal),
                      padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                      textStyle:
                      MaterialStateProperty.all(TextStyle(fontSize: 18))),
                  onPressed: () {
                    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) { });
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            content: Container(
                              child: _Timer(),
                              height: 200,
                            ),
                            actions: [
                              ElevatedButton(
                                child: Text("끄기"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                ElevatedButton(
                  child: Text('돌아가기'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                      textStyle:
                      MaterialStateProperty.all(TextStyle(fontSize: 18))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Timer extends StatefulWidget {
  const _Timer({Key? key}) : super(key: key);
  @override
  State<_Timer> createState() => __TimerState();
}

class Ticker {
  const Ticker();
  Stream<int> tick() {
    return Stream.periodic(Duration(seconds: 1), (x) => x);
  }
}
class __TimerState extends State<_Timer> {
  late StreamSubscription<int> subscription;
  int? _currentTick;
  bool _isPaused = false;
  bool _isFirst = true;

  @override
  initState() {
    super.initState();
    _start();
    _pause();
  }

  void _start() {
    subscription = Ticker().tick().listen((value) {
      setState(() {
        _isPaused = false;
        _currentTick = value;
      });
    });
  }

  void _resume() {
    setState(() {
      _isPaused = false;
    });
    subscription.resume();
  }

  void _pause() {
    setState(() {
      _isPaused = true;
    });
    subscription.pause();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
              //color:  Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Text(
              _currentTick == null ? 'start' :
              (int.parse(_currentTick.toString())~/60).toString().padLeft(2,'0') + ' : ' + (int.parse(_currentTick.toString())%60).toString().padLeft(2,'0'),
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                subscription.cancel();
                _start();
                _isFirst = false;
              },
                  child: Text(_isFirst ? '시작' : '초기화')),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(onPressed: () {
                _isPaused ? _resume() : _pause();
              },
                  child: Text(_isPaused ? '계속' : '일시정지'))
            ],
          )
        ],
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ); // scc;
  }
}