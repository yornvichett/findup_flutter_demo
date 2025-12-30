import 'package:flutter/material.dart';

class DialogPopUpElements extends StatefulWidget {
  final Future<void> Function() onProcess;
  String message;
  String subTitle;
  IconData icon;
  Color iconColor;
  bool isShowIcon;
  DialogPopUpElements({
    super.key,
    required this.onProcess,
    this.message = "Published.",
    this.subTitle='',
    this.isShowIcon = true,
    this.iconColor = Colors.green,
    this.icon = Icons.check_circle_outline,
  });

  @override
  _DialogPopUpElementsState createState() => _DialogPopUpElementsState();
}

class _DialogPopUpElementsState extends State<DialogPopUpElements>
    with SingleTickerProviderStateMixin {
  bool _showCheck = true; // show immediately

  @override
  void initState() {
    super.initState();
    // Run the async process in the background
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.onProcess(); // wait for posting property
      if (mounted) Navigator.of(context).pop(); // close popup when done
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // make dialog background transparent
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isShowIcon
              ? AnimatedScale(
                  scale: _showCheck ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Icon(widget.icon, color: widget.iconColor, size: 60),
                )
              : SizedBox(),
           SizedBox(height: 16),
          Text(
            widget.message,
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.subTitle,
            style: TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
