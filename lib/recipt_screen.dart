import "package:flutter/material.dart";

class ReciptScreen extends StatelessWidget {
  final String recipeName;
  final String reciptData;
  const ReciptScreen(this.recipeName, this.reciptData);

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
            Container( // 레시피 내용 들어가는 컨테이너
              color: Colors.white,
                child: Text('레시피 : $reciptData')
            ),
            ElevatedButton(
              child: Text('돌아가기'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}