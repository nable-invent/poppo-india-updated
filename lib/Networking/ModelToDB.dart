class Table {
  final String columnName;
  final String columnType;
  final String isNull;
  Table({
    this.columnName,
    this.columnType,
    this.isNull,
  });
}

String checkdataType(String type) {
  switch (type) {
    case "int":
      return "interger".toUpperCase();
    case "String":
      return "Text".toUpperCase();
    case "double":
      return "double".toUpperCase();
    default:
      return type.toUpperCase();
  }
}
