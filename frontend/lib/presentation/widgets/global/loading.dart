import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color.fromARGB(55, 0, 0, 0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
