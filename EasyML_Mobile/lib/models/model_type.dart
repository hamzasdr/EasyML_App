
class ModelType {
  String name;
  String programmaticName;
  String shortDescription;
  String longDescription;
  String imageUrl;
  ModelCategory category;
  Function createModel;

  ModelType({
    this.name,
    this.programmaticName,
    this.shortDescription,
    this.longDescription,
    this.imageUrl,
    this.category,
    this.createModel
  });

  factory ModelType.fromJson(Map<String, dynamic> json) {
    return ModelType(
      name: json['name'] as String,
      programmaticName: json['programmaticName'] as String,
      shortDescription: json['shortDescription'] as String,
      longDescription: json['longDescription'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  String get categoryName {
    switch(category){
      case ModelCategory.CLASSIFICATION:
        return 'Classification';
      case ModelCategory.REGRESSION:
        return 'Regression';
      case ModelCategory.CLUSTERING:
        return 'Clustering';
      default:
        return '';
    }
  }
}

enum ModelCategory{
  CLASSIFICATION,
  REGRESSION,
  CLUSTERING

}