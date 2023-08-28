import 'package:lightshot_parser/parser.dart';


void main() async {
  var parser = LightshotParser();
  parser.parse(100); // How many files do you want to download
}

