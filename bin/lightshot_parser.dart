import 'package:lightshot_parser/parser.dart';


void main() async {
  var parser = LightshotParser();

  parser.parse(
      numOfPhotos: 1000,
      newAddresses: false,
      startingUrl: ''
  );
}

