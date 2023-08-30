import 'package:lightshot_parser/parser.dart';


void main() async {
  var parser = LightshotParser();
  parser.parse(
      50,                                                                       //How many photo you want to download;
      newAddresses: false,                                                      //Do you want to parse new addresses(have 12 characters instead of 6);
      startingUrl: 'aaaaaa'                                                     //Do you want to start parsing with your Url; if startingUrl is missing, use random Url generator
  );
}

