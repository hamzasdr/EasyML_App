class DataSet{
  static final Map<String, Map> types = {
    'csv': {
      'name': 'Comma-separated Values',
      'description': 'Comma-seperated values files represent simple tabular data by using text values that are seperated with commas to indicate table cells.',
      'extensions': ['csv']
    },
    'excel': {
      'name': 'Excel/OpenDocument Spreadsheet',
      'description': 'Microshoft Excel or Open Document Spreadsheets. Supports .xls, .xlsx and .ods extensions. The first sheet in the file will be used as the data set.',
      'extensions': ['xls', 'xlsx', 'ods']
    },
    'json': {
      'name': 'JSON',
      'description':'Javascript Object Notation files.'
          'Its format is a JSON object containing an array of column names, "columns", an array of arrays of data values, "data", and an optional array of indecies, "index".',
      'extensions': ['json', 'txt']
    },
//    'sql': {
//      'name': 'SQL',
//      'description': 'sql description',
//      'extensions': ['sql']
//    }
  };

  int id;
  String name;
  String type;
  Map<String, dynamic> info;

  DataSet({this.id, this.name, type, this.info}){
    if(!types.containsKey(type))
      type = null;
    this.type = type;
  }

  factory DataSet.fromJson(Map<String, dynamic> json){
    if(!types.containsKey(json['type']))
      json['type'] = null;
    return DataSet(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      info: json['info'] as Map ?? {}
    );
  }

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'type': type,
      'info': info
  };

  List get columns {
    if(info.containsKey('columns'))
        return info['columns'];
    else
        return [];
  }

  @override
  String toString() {
    return name;
  }
}