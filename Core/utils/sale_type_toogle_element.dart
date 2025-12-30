import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:flutter/material.dart';

class SaleTypeToogleElement extends StatefulWidget {
  Function(Map<String,dynamic> json) onTab;
  SaleTypeToogleElement({super.key,required this.onTab});

  @override
  State<SaleTypeToogleElement> createState() => _SaleTypeToogleElementState();
}

class _SaleTypeToogleElementState extends State<SaleTypeToogleElement> {
  ValueNotifier<bool> isSale = ValueNotifier(true); 

 // true = Sale, false = Rent
  List<Map<String, dynamic>> listSaleType = [
    {'id': 1, 'key_translate': 'rent', 'title': 'Rent', 'is_selected': true},
    {'id': 2, 'key_translate': 'sale', 'title': 'Sale', 'is_selected': false},
    
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: listSaleType
            .map(
              (e) => GestureDetector(
                onTap: () {
                  for (var item in listSaleType) {
                    item['is_selected'] = false;
                  }
                  e['is_selected'] = true;
                  widget.onTab(e);
                  isSale.value = !isSale.value;
                },
                child: ValueListenableBuilder(
                  valueListenable: isSale,
                  builder: (context, value, child) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: e['is_selected'] == true
                            ? e['title'] == 'Sale'
                                  ? Colors.red
                                  : Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        Translator.translate(e['key_translate']),
                        style: TextStyle(
                          color: e['is_selected'] == true ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
