import 'dart:convert';

/// Allows lookup by Header
class CsvRow {
  final int number;
  final List<String> values;

  CsvRow(this.number, this.values);

  String operator [](var lookup) => values[lookup as int];
}

/// Allows lookup by Header
class CsvRowWithHeaders extends CsvRow {
  final Map<String, int> headerIndexes;

  CsvRowWithHeaders(int number, List<String> values, this.headerIndexes)
      : super(number, values);

  @override
  String operator [](var lookup) {
    var index = lookup;
    if (lookup is String) {
      index = headerIndexes[lookup];
    }
    return super[index];
  }
}

typedef CsvRowHandler = void Function(CsvRow csvRow);

class CsvReader {
  final Stream source;
  final String separator;
  final bool headers;
  final int headersRow;
  final int firstDataRow;

  CsvReader(this.source, this.separator, this.headers, this.headersRow, this.firstDataRow);

  CsvReader.csv(Stream source,
      {String separator = ',',
      bool headers = false,
      int headersRow = 0,
      int firstDataRow = 0})
      : this(source, separator, headers, headersRow, firstDataRow);

  CsvReader.tsv(Stream source,
      {bool headers = false, int headersRow = 0, int firstDataRow = 0})
      : this(source, '\t', headers, headersRow, firstDataRow);

  void eachRow(CsvRowHandler rowHandler) {
    rows().listen(rowHandler);
  }

  Stream<CsvRow> rows() async* {
    int rowNumber = -1;
    Map<String, int> headerToIndex = {};

    var lines = source.transform(utf8.decoder).transform(LineSplitter());
    await for(String line in lines ) {
      rowNumber++;
      final parts = line.split(separator);

      if (headers && rowNumber == headersRow) {
        // header row
        for (var i = 0; i < parts.length; i++) {
          var header = parts[i]?.trim();
          headerToIndex[header] = i;
        }
      } else if (rowNumber >= firstDataRow) {
        // every other row after data starts
        var trimmedValues = parts.map((part) => part.trim()).toList();
        CsvRow row;
        if (headers) {
          row = CsvRowWithHeaders(rowNumber, trimmedValues, headerToIndex);
        } else {
          row = CsvRow(rowNumber, trimmedValues);
        }
        yield row;
      }
    }
  }
}
