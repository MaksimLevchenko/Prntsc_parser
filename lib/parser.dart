import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import "dart:core";


final Random r = Random();

class LightshotParser{

  late final _possibleSymbolsInOldUrl = "qwertyuiopasdfghjklzxcvbnm1234567890";
  late final _possibleSymbolsInNewUrl = "_QWERTYUIOPASDFGHJKLZXCVBNM-$_possibleSymbolsInOldUrl";

  getImage(Uri url) async{
    try {
      final responseFromSite = await http.get(url);
      final sourceCode = responseFromSite.body;
      final RegExp imgPattern = RegExp(r'https.*png');

      if (responseFromSite.statusCode != 200) {
        throw Exception('Can\'t reach server : ${responseFromSite.statusCode}');
      }

      var imageStringUrl = imgPattern.stringMatch(sourceCode);

      if (imageStringUrl == null) {
        throw Exception("The photo is missing");
      }

      imageStringUrl = imageStringUrl.substring(
          0,
          imageStringUrl.indexOf('"')
      );

      if (!imageStringUrl.contains(imgPattern)) {
        throw Exception("The photo is missing");
      }

      var imageUrl = Uri.parse(imageStringUrl);
      http.get(imageUrl).then((response) {
        File(
            'Photos/${imageUrl.pathSegments[imageUrl.pathSegments.length - 1]}'
        ).writeAsBytes(response.bodyBytes);
      });
    } catch(e) {
      print("There is an exception. $e with $url");
    }
  }

  Uri getRandomUrl([newAddresses = false]) {
    var usingSymbols = newAddresses ? _possibleSymbolsInNewUrl : _possibleSymbolsInOldUrl;
    var numberOfSymbols = newAddresses ? 12 : 5;
    late String stringUrl;

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => usingSymbols.codeUnitAt(r.nextInt(usingSymbols.length))));

    stringUrl = getRandomString(numberOfSymbols);

    var url = Uri.parse("https://prnt.sc/$stringUrl");
    return url;
  }

  void parse(int numOfIterations, [newAddresses = false]){
    for (int i = 0; i < numOfIterations; i++){
      getImage(getRandomUrl(newAddresses));
    }
  }
}
