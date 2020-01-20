import 'dart:io';

import 'package:dart_csv/dart_csv.dart';

class Car {
  final String year, make, model;

  Car(this.year, this.make, this.model);
}

void main() async {
  var reader = CsvReader.csv(await File('example.csv').openRead(),
      headers: true, firstDataRow: 1);

  // do something per row manually
  reader.eachRow((row) {
    // column order - Year,Make,Model,Length
    // print format - row-number: Make Model (Year)
    print("${row.number}: ${row[1]} ${row[2]} (${row['Year']})");
  });

  print("");
  print("BREAK");
  print("");

  // transform rows into objects.
  reader = CsvReader.csv(await File('example.csv').openRead(),
      headers: true, firstDataRow: 1);

  var cars = await reader
      .rows()
      .map((row) => Car(row['Year'], row['Make'], row['Model'])).toList();

  cars.forEach((car) => print("${car.make} ${car.model} (${car.year})"));
}
