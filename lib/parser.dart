import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import "dart:core";


class LightshotParser{
  HttpClient client = HttpClient();


  LightshotParser() {
    client.userAgent =
        'Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0'; // It is necessary in order not to be banned immediately
    var photos = Directory("Photos");
    if (!photos.existsSync()) photos.create();                                  // Create photos directory if it s missing

  }


  getImage(Uri url) async{
    try {
      final responseFromSite = await http.get(url);
      final sourceCode = responseFromSite.body;
      final RegExp imgPattern = RegExp(r'https.*((png)|(jpg)|(jpeg))');

      if (responseFromSite.statusCode != 200) {
        throw Exception('Can\'t reach server : ${responseFromSite.statusCode}');
      }

      var imageStringUrl = imgPattern.stringMatch(sourceCode);                  //looking for a direct address to the photo

      if (imageStringUrl == null) {
        throw Exception("The photo is missing");
      }

      imageStringUrl = imageStringUrl.substring(
          0,
          imageStringUrl.indexOf('"')
      );                                                                        //Cutting the image url after .jpg or .png

      if (!imageStringUrl.contains(imgPattern)) {
        throw Exception("The photo is missing");
      }

      var imageUrl = Uri.parse(imageStringUrl);
      final responseFromImg = await http.get(imageUrl);

      if (responseFromImg.statusCode != 200){
        throw Exception(
            "The photo is missing with ${responseFromImg.statusCode}"
        );
      }
      if (responseFromImg.bodyBytes.length == 503) {                            //We filter out the imgur stubs that have 503 bites size
        throw Exception(
            "The photo $imageStringUrl is imgur stub"
        );
      }

      await File(
          'Photos/${imageUrl.pathSegments[imageUrl.pathSegments.length - 1]}'   //Download the photo
      ).writeAsBytes(responseFromImg.bodyBytes);

      print('file $imageStringUrl from $url downloaded successful');
      return 1;
    } catch(e) {
      print("There is an exception. $e with $url");
      return 0;
    }
  }

  void parse(
      int numOfPhotos,
      {bool newAddresses = false, String startingUrl = ''})
  async {
    var getUrl = startingUrl == ''
        ? GetRandomUrl(newAddresses)
        : GetNextUrl(newAddresses, startingUrl);
    for (num i = 0; i < numOfPhotos;){
      getUrl.moveNext();
      i += await getImage(getUrl.current);
      await Future.delayed(Duration(milliseconds: 70));                         // It is necessary in order not to be banned
    }
    print("Successfully downloaded $numOfPhotos photos");
  }
}


class GetNextUrl implements Iterator<Uri>{
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late List<int> _charsNumbers;
  late String _stringUrl;
  late Uri url;

  GetNextUrl([this.newAddresses = false, stringUrl]){
    _possibleSymbolsInOldUrl = "abcdefghijklmnopqrstuvwxyz1234567890";
    _possibleSymbolsInNewUrl = "${_possibleSymbolsInOldUrl}ABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
    _usingSymbols = newAddresses
        ? _possibleSymbolsInNewUrl
        : _possibleSymbolsInOldUrl;
    _numberOfSymbols = newAddresses ? 12 : 6;
    _stringUrl = stringUrl;
    if (_stringUrl.length != _numberOfSymbols) {
      _stringUrl = List<String>.filled(_numberOfSymbols, 'q').join('');
    }
    _charsNumbers = charsFromString(_stringUrl);
  }

  List<int> charsFromString(String stringUrl){
    List<int> result = List<int>.generate(
        _numberOfSymbols
        , (index) => _usingSymbols.indexOf(stringUrl[index]));
    return result;
  }

  @override
  Uri get current => url;

  @override bool moveNext(){
    _stringUrl = '';
    _charsNumbers.last += 1;
    for (int i = 0; i < _numberOfSymbols; i++) {                                //Check if the symbol number has reached the limit
      if (_charsNumbers[i] == _usingSymbols.length){
        _charsNumbers[i] = 0;
        if(i != 0) _charsNumbers[i - 1] += 1;
      }
      _stringUrl += _usingSymbols[_charsNumbers[i]];                            //Adding the characters corresponding to the numbers to the stringUrl
    }
    url = Uri.parse("https://prnt.sc/$_stringUrl");
    return true;
  }
}

class GetRandomUrl implements Iterator<Uri>{
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late String _stringUrl;
  late Uri url;

  GetRandomUrl([this.newAddresses = false]){
    _possibleSymbolsInOldUrl = "abcdefghijklmnopqrstuvwxyz1234567890";
    _possibleSymbolsInNewUrl = "${_possibleSymbolsInOldUrl}ABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
    _usingSymbols = newAddresses
        ? _possibleSymbolsInNewUrl
        : _possibleSymbolsInOldUrl;
    _numberOfSymbols = newAddresses ? 12 : 6;
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate
    (length, (_) => _usingSymbols.codeUnitAt(Random().nextInt(_usingSymbols.length))));

  @override
  Uri get current => url;

  @override
  bool moveNext(){
    _stringUrl = getRandomString(_numberOfSymbols);
    url = Uri.parse("https://prnt.sc/$_stringUrl");
    return true;
  }
}
