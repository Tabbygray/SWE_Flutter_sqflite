import "package:flutter/material.dart";

class ReciptScreen extends StatelessWidget {
  const ReciptScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Center(
        child: ElevatedButton(
          child: const Text('돌아가기'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}