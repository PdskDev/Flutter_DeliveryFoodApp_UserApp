import 'package:flutter/material.dart';
import 'package:users_app/widgets/progress_bar.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(),
          const SizedBox(height: 10,),
          Text("${message!}, please wait..."),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}
