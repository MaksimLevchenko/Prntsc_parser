import 'dart:io';
import 'package:lightshot_parser/parser.dart';


void main() {
  var parser = LightshotParser();
  print('Enter the desired number of images');
  int num = int.parse(stdin.readLineSync() ?? '10');
  print('Do you want to use 12-character addresses? (y/n)');
  bool newAdr = (stdin.readLineSync() ?? 'n') == 'y' ? true : false;
  print('Do you want to set the initial Url (${newAdr == true ? 12 : 6} characters)?'
        ' Skip it if you want a random selection');
  String start = stdin.readLineSync() ?? '';
  parser.parse(
      numOfImages: num,
      newAddresses: newAdr,
      startingUrl: start
  );
}

