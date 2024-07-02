import 'dart:io';

import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';

class CommonModal{
  
  static Future buildMultiSelectDialogField({
    required BuildContext context,
    String label = "Tercih yapınız",
    String hintText = "Arama",
    bool showSearchBox = false,
    required List<dynamic> itemList,
    required dynamic multipleSelectedValues,
    required void Function(List<dynamic>)? onMultipleItemsChange,
    required Widget Function(BuildContext, dynamic, bool)? itemBuilder,
  }) async {
    SelectDialog.showModal<dynamic>(
      context,
      label: label,
      titleStyle: TextStyle(fontWeight: Platform.isMacOS ? FontWeight.w300 : FontWeight.normal, color: Colors.deepOrange, fontSize: 22),
      multipleSelectedValues: multipleSelectedValues,
      items: itemList,
      searchBoxDecoration: InputDecoration(hintText: hintText),
      showSearchBox: showSearchBox,
      alwaysShowScrollBar: true,
      itemBuilder: itemBuilder,
      onMultipleItemsChange: onMultipleItemsChange,
      emptyBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            "Seçenek Bulunamadı.\nForm dışına tıklayarak sayfadan çıkış yapabilirsiniz.",
            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: Platform.isMacOS ? FontWeight.w300 : FontWeight.normal),
          ),
        ),
      ),
    
      okButtonBuilder: (context, onPressed) => 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              child: const Text("Tamam"),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Vazgeç"),
            ),
          ],
      ),

    );
  }

}