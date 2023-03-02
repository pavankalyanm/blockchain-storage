import 'package:flutter/material.dart';
import 'package:todo_app/globals.dart' as globals;

class displayImage extends StatelessWidget {
  const displayImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Certificate"),
        ),
        body: Center(
            child: Image.network(globals.link,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return child;
        }, loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        })));
  }
}
