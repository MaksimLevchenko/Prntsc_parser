import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import "dart:core";


class LightshotParser {
  LightshotParser() {
    // It is necessary in order not to be banned immediately
    HttpClient client = HttpClient();
    client.userAgent =
        'Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0';
    var photos = Directory("Photos");
    if (!photos.existsSync()) photos.create();
  }

  ///downloading image from {prnt.sc} url
  getImage(Uri url) async {
    try {
      final responseFromSite = await http.get(url);
      final sourceCode = responseFromSite.body;
      final RegExp imgPattern = RegExp(r'https.*((png)|(jpg)|(jpeg))');

      switch (responseFromSite.statusCode) {
        case 503:
          await Future.delayed(Duration(seconds: 10));
          throw Exception('Server wants to ban you. Waiting');
        case 403:
          throw Exception('We got banned');
        case 200:
          break;
        default:
          throw Exception(
              'Can\'t reach server : ${responseFromSite.statusCode}');
      }

      //looking for a direct address to the file
      var imageStringUrl = imgPattern.stringMatch(sourceCode);

      if (imageStringUrl == null) {
        throw Exception("The photo is missing");
      }

      //Cutting the image url after .jpg or .png
      imageStringUrl = imageStringUrl.substring(0, imageStringUrl.indexOf('"'));

      if (!imageStringUrl.contains(imgPattern)) {
        throw Exception("The photo is missing");
      }

      var imageUrl = Uri.parse(imageStringUrl);
      final responseFromImg = await http.get(imageUrl);

      if (responseFromImg.statusCode != 200) {
        throw Exception(
            "The photo is missing with ${responseFromImg.statusCode}");
      }

      //We filter out the imgur stubs that have 503 bites size
      if (responseFromImg.bodyBytes.length == 503) {
        throw Exception("The photo $imageStringUrl is imgur stub");
      }

      //Download the photo
      await File(
              'Photos/${imageUrl.pathSegments[imageUrl.
              pathSegments.length - 1]}')
          .writeAsBytes(responseFromImg.bodyBytes);

      print('file $imageStringUrl from $url downloaded successful');
      return 1;
    } catch (e) {
      print("There is an exception. $e with $url");
      return 0;
    }
  }

  /// Start parsing
  ///
  /// Downloads numOfPhotos in new if newAddresses urls
  /// starting from startingUrl. If startingUrl == '' uses random Url generator
  /// otherwise - contractor Url generator
  void parse(
      {int numOfPhotos = 100,
      bool newAddresses = false,
      String startingUrl = ''}) async {
    var getUrl = startingUrl == ''
        ? GetRandomUrl(newAddresses)
        : GetNextUrl(newAddresses, startingUrl);

    // delay is necessary in order not to be banned
    for (num i = 0; i < numOfPhotos;) {
      i += await getImage(getUrl.current);
      getUrl.moveNext();
    }
    print("Successfully downloaded $numOfPhotos photos");
  }
}


/// Generates contractor Urls starting from stringUrl
class GetNextUrl implements Iterator<Uri> {
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late List<int> _charsNumbers;
  late String _stringUrl;

  GetNextUrl([this.newAddresses = false, stringUrl]) {
    _possibleSymbolsInOldUrl = "abcdefghijklmnopqrstuvwxyz1234567890";
    _possibleSymbolsInNewUrl =
        "${_possibleSymbolsInOldUrl}ABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
    _usingSymbols =
        newAddresses ? _possibleSymbolsInNewUrl : _possibleSymbolsInOldUrl;
    _numberOfSymbols = newAddresses ? 12 : 6;
    _stringUrl = stringUrl;
    if (_stringUrl.length != _numberOfSymbols) {
      _stringUrl = List<String>.filled(_numberOfSymbols, 'q').join('');
    }
    _charsNumbers = charsFromString(_stringUrl);
  }

  @override
  Uri get current => Uri.parse("https://prnt.sc/$_stringUrl");

  @override
  bool moveNext() {
    _stringUrl = '';
    _charsNumbers.last += 1;
    for (int i = 0; i < _numberOfSymbols; i++) {
      //Check if the symbol number has reached the limit
      if (_charsNumbers[i] == _usingSymbols.length) {
        _charsNumbers[i] = 0;
        if (i != 0) _charsNumbers[i - 1] += 1;
      }
      //Adding the characters corresponding to the numbers to the stringUrl
      _stringUrl += _usingSymbols[_charsNumbers[i]];
    }
    return true;
  }

  List<int> charsFromString(String stringUrl) {
    List<int> result = List<int>.generate(
        _numberOfSymbols, (index) => _usingSymbols.indexOf(stringUrl[index]));
    return result;
  }
}


///Generates random Url
class GetRandomUrl implements Iterator<Uri> {
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late String _stringUrl;

  GetRandomUrl([this.newAddresses = false]) {
    _possibleSymbolsInOldUrl = "abcdefghijklmnopqrstuvwxyz1234567890";
    _possibleSymbolsInNewUrl =
        "${_possibleSymbolsInOldUrl}ABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
    _usingSymbols =
        newAddresses ? _possibleSymbolsInNewUrl : _possibleSymbolsInOldUrl;
    _numberOfSymbols = newAddresses ? 12 : 6;
    _stringUrl = getRandomString(_numberOfSymbols);
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length,
      (_) => _usingSymbols.codeUnitAt(Random().nextInt(_usingSymbols.length))));

  @override
  Uri get current => Uri.parse("https://prnt.sc/$_stringUrl");

  @override
  bool moveNext() {
    _stringUrl = getRandomString(_numberOfSymbols);
    return true;
  }
}
