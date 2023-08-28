import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import "dart:core";


final Random r = Random();

class LightshotParser{
  late final _possibleSymbolsInOldUrl = "qwertyuiopasdfghjklzxcvbnm123456789";
  late final _possibleSymbolsInNewUrl = "_QWERTYUIOPASDFGHJKLZXCVBNM-$_possibleSymbolsInOldUrl";
  HttpClient client = HttpClient();
  LightshotParser() {
    client.userAgent =
        'Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0';
  }

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
      final responseFromImg = await http.get(imageUrl);
      if (responseFromImg.statusCode != 200){
        throw Exception("The photo is missing with ${responseFromImg.statusCode}");
      }
      await File('Photos/${imageUrl.pathSegments[imageUrl.pathSegments.length - 1]}')
          .writeAsBytes(responseFromImg.bodyBytes);

      // http.get(imageUrl).then((response) {
      //   File(
      //       'Photos/${imageUrl.pathSegments[imageUrl.pathSegments.length - 1]}'
      //   ).writeAsBytes(response.bodyBytes);
      // });
      print('file $imageStringUrl downloaded successful');
      return 1;
    } catch(e) {
      print("There is an exception. $e with $url");
      return 0;
    }
  }

  Uri getRandomUrl([newAddresses = false]) {
    var usingSymbols = newAddresses ? _possibleSymbolsInNewUrl : _possibleSymbolsInOldUrl;
    var numberOfSymbols = newAddresses ? 12 : 6;
    late String stringUrl;

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => usingSymbols.codeUnitAt(r.nextInt(usingSymbols.length))));

    stringUrl = getRandomString(numberOfSymbols);


    var url = Uri.parse("https://prnt.sc/$stringUrl");
    return url;
  }

  void parse(int numOfIterations, [newAddresses = false]) async {
    for (num i = 0; i < numOfIterations;){
      i += await getImage(getRandomUrl(newAddresses));
      await Future.delayed(Duration(seconds: 1));
    }
  }
}
