import 'dart:io';

class EditableImage {
  final String? url; // existing network image
  final File? file;  // newly picked image

  EditableImage({this.url, this.file});

  bool get isNetwork => url != null;
}
