import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sea/services/fb_storage.dart';

class TextModeratorResponse {
  final bool reviewRecommended;
  final double sexuallyExplicit;
  final double sexuallySuggestive;
  final double offensive;
  final List<String> terms;

  TextModeratorResponse({
    required this.reviewRecommended,
    required this.sexuallyExplicit,
    required this.sexuallySuggestive,
    required this.offensive,
    required this.terms,
  });
}

class ImageModeratorResponse {
  final bool isImageAdultClassified;
  final double adultClassificationScore;
  final bool isImageRacyClassified;
  final double racyClassificationScore;

  ImageModeratorResponse({
    required this.isImageAdultClassified,
    required this.adultClassificationScore,
    required this.isImageRacyClassified,
    required this.racyClassificationScore,
  });
}

class Moderator {

  static Future<TextModeratorResponse?> evaluateTextInput(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://seamobile.cognitiveservices.azure.com//contentmoderator/moderate/v1.0/ProcessText/Screen'
            '?autocorrect=True&PII=True&classify=True'),
        headers: {
          'Ocp-Apim-Subscription-Key': '94db6a09ca044cce827eaa0c946aa02a',
          'Content-Type': 'text/plain',
        },
        body: text,
      );

      final decodedResponse = jsonDecode(response.body);

      print(decodedResponse);

      List<String> terms = [];

      if(decodedResponse['Terms'] != null && decodedResponse['Terms'].isNotEmpty) {
        for(dynamic term in decodedResponse['Terms']) {
          terms.add(term['Term']);
        }
      }
      return TextModeratorResponse(
        reviewRecommended: decodedResponse['Classification']['ReviewRecommended'],
        sexuallyExplicit: decodedResponse['Classification']['Category1']['Score'],
        sexuallySuggestive: decodedResponse['Classification']['Category2']['Score'],
        offensive: decodedResponse['Classification']['Category3']['Score'],
        terms: terms,
      );
    } catch(e) {
      print('fail');
      return null;
    }
  }

  static Future<ImageModeratorResponse?> evaluateImageInput(String imageURL) async {
    try {

      // var headers =  {
      //   'Ocp-Apim-Subscription-Key': '94db6a09ca044cce827eaa0c946aa02a',
      //   'Content-Type': 'image/png',
      // };
      // var request = http.MultipartRequest(
      //   "POST",
      //   Uri.parse('https://seamobile.cognitiveservices.azure.com//contentmoderator/moderate/v1.0/ProcessImage/Evaluate?CacheImage=True'),
      // );
      //
      // final compressedImage = await FBStorage.compressImage(file);
      //
      // request.headers.addAll(headers);
      // request.files.add( http.MultipartFile.fromBytes("body", compressedImage.readAsBytesSync(), contentType: MediaType('image', 'png')));
      //
      // var response = await request.send();
      // print(await response.stream.transform(utf8.decoder).join());


      final response = await http.post(
        Uri.parse('https://seamobile.cognitiveservices.azure.com/contentmoderator/moderate/v1.0/ProcessImage/Evaluate?CacheImage=True'),
        headers: {
          'Ocp-Apim-Subscription-Key': '94db6a09ca044cce827eaa0c946aa02a',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "DataRepresentation":"URL",
          "Value": imageURL,
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      print(decodedResponse);

      return ImageModeratorResponse(
        isImageAdultClassified: decodedResponse['IsImageAdultClassified'],
        adultClassificationScore: decodedResponse['AdultClassificationScore'],
        isImageRacyClassified: decodedResponse['IsImageRacyClassified'],
        racyClassificationScore: decodedResponse['RacyClassificationScore'],
      );
    } catch(e) {
      print('fail');
      print(e.toString());
      return null;
    }
  }

  // static Future<String?> evaluateText(String text) async {
  //   var body = json.encode({
  //     'text': text,
  //   });
  //   final response = await http.post(
  //     Uri.parse('https://classify.oterlu.com/v1/text'),
  //     headers: {
  //       'x-api-key': '4881c8a4-f88f-4dfb-9655-c0bc3439a23e',
  //       'Content-Type': 'application/json',
  //     },
  //     body: body,
  //   );
  //
  //   print(response.body);
  //
  //   return 'success';
  //
  // }
}
