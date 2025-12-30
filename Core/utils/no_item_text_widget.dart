import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:flutter/cupertino.dart';

class NoItemTextWidget extends StatelessWidget {
  const NoItemTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Text(Translator.translate('no_item_found')),
      ),
    );
  }
}
