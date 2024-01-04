import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;

  const ErrorDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          onPressed: () { Navigator.pop(context); },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
          ),
          child: const Center(
            child: Text("OK", style: TextStyle(
              color: Colors.white
            ),),
          ),
        )
      ],
    );
  }
}
