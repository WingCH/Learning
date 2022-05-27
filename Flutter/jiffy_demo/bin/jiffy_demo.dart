import 'package:jiffy/jiffy.dart';

void main(List<String> arguments) {
  var date = DateTime(2018, 5, 31);
  var dateJiffy = Jiffy(date);
  print(dateJiffy.dateTime);
  dateJiffy.subtract(months: 12);
  print(dateJiffy.dateTime);
}
