import 'dart:math';


/// Generates contractor Urls starting from stringUrl
class GetNextUrl implements Iterator<Uri>{
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late List<int> _charsNumbers;
  late String _stringUrl;

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

  @override
  Uri get current => Uri.parse("https://prnt.sc/$_stringUrl");

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
    return true;
  }

  List<int> charsFromString(String stringUrl){
    List<int> result = List<int>.generate(
        _numberOfSymbols
        , (index) => _usingSymbols.indexOf(stringUrl[index]));
    return result;
  }

}


///Generates random Url
class GetRandomUrl implements Iterator<Uri>{
  late bool newAddresses;
  late final String _possibleSymbolsInOldUrl;
  late final String _possibleSymbolsInNewUrl;
  late final String _usingSymbols;
  late final int _numberOfSymbols;
  late String _stringUrl;

  GetRandomUrl([this.newAddresses = false]){
    _possibleSymbolsInOldUrl = "abcdefghijklmnopqrstuvwxyz1234567890";
    _possibleSymbolsInNewUrl = "${_possibleSymbolsInOldUrl}ABCDEFGHIJKLMNOPQRSTUVWXYZ_-";
    _usingSymbols = newAddresses
        ? _possibleSymbolsInNewUrl
        : _possibleSymbolsInOldUrl;
    _numberOfSymbols = newAddresses ? 12 : 6;
    _stringUrl = getRandomString(_numberOfSymbols);
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate
    (length, (_) => _usingSymbols.codeUnitAt(Random().nextInt(_usingSymbols.length))));

  @override
  Uri get current => Uri.parse("https://prnt.sc/$_stringUrl");

  @override
  bool moveNext(){
    _stringUrl = getRandomString(_numberOfSymbols);
    return true;
  }
}