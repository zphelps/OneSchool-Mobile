// import 'package:flutter/material.dart';
//
// class MaskedTextController extends TextEditingController {
//
//   MaskedTextController({String? text, required this.mask, Map<String, RegExp>? translator})
//       : super(text: text) {
//     translator = translator ?? MaskedTextController.getDefaultTranslator();
//
//     addListener(() {
//       var previous = _lastUpdatedText;
//       if (beforeChange(previous, this.text)) {
//         updateText(this.text);
//         afterChange(previous, this.text);
//       } else {
//         updateText(_lastUpdatedText);
//       }
//     });
//
//     updateText(this.text);
//   }
//
//   String mask;
//
//   late Map<String, RegExp> translator;
//
//   Function afterChange = (String previous, String next) {};
//   Function beforeChange = (String previous, String next) {
//     return true;
//   };
//
//   String _lastUpdatedText = '';
//
//   void updateText(String text) {
//     if(text != null){
//       this.text = this._applyMask(this.mask, text);
//     }
//     else {
//       this.text = '';
//     }
//
//     this._lastUpdatedText = this.text;
//   }
//
//   void updateMask(String mask, {bool moveCursorToEnd = true}) {
//     this.mask = mask;
//     this.updateText(this.text);
//
//     if (moveCursorToEnd) {
//       this.moveCursorToEnd();
//     }
//   }
//
//   void moveCursorToEnd() {
//     var text = this._lastUpdatedText;
//     this.selection = new TextSelection.fromPosition(
//         new TextPosition(offset: (text ?? '').length));
//   }
//
//   @override
//   void set text(String newText) {
//     if (super.text != newText) {
//       super.text = newText;
//       this.moveCursorToEnd();
//     }
//   }
//
//   static Map<String, RegExp> getDefaultTranslator() {
//     return {
//       'A': new RegExp(r'[A-Za-z]'),
//       '0': new RegExp(r'[0-9]'),
//       '@': new RegExp(r'[A-Za-z0-9]'),
//       '*': new RegExp(r'.*')
//     };
//   }
//
//   String _applyMask(String mask, String value) {
//     String result = '';
//
//     var maskCharIndex = 0;
//     var valueCharIndex = 0;
//
//     while (true) {
//       // if mask is ended, break.
//       if (maskCharIndex == mask.length) {
//         break;
//       }
//
//       // if value is ended, break.
//       if (valueCharIndex == value.length) {
//         break;
//       }
//
//       var maskChar = mask[maskCharIndex];
//       var valueChar = value[valueCharIndex];
//
//       // value equals mask, just set
//       if (maskChar == valueChar) {
//         result += maskChar;
//         valueCharIndex += 1;
//         maskCharIndex += 1;
//         continue;
//       }
//
//       // apply translator if match
//       if (translator.containsKey(maskChar)) {
//         if (translator[maskChar]!.hasMatch(valueChar)) {
//           result += valueChar;
//           maskCharIndex += 1;
//         }
//
//         valueCharIndex += 1;
//         continue;
//       }
//
//       // not masked value, fixed char on mask
//       result += maskChar;
//       maskCharIndex += 1;
//       continue;
//     }
//
//     return result;
//   }
// }