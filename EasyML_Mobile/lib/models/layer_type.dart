import 'dart:convert';
class Layer{
  int id = -1;
  String type;
  String activationFunction;
  String imageUrl;
  Layer({
    this.id,
    this.type,
    this.activationFunction,
    this.imageUrl
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'activationFunction': activationFunction,
    'imageUrl': imageUrl
  };

  factory Layer.fromJson(Map<String, dynamic> json) {
    String type = json['type'] as String;
    switch(type){
      case 'dense':
        return DenseLayer(
          imageUrl: 'assets/images/brain.png',
          type: json['type'] as String,
          id: json['id'] as int,
          activationFunction: json['activationFunction'] as String,
          numberOfNodes: json['numberOfNodes'] as int
        );
      case 'conv':
        return ConvolutionalLayer(
            imageUrl: 'assets/images/brain.png',
            type: json['type'] as String,
            id: json['id'] as int,
            activationFunction: json['activationFunction'] as String,
            filter: json['filter'] as int,
            kernel1: json['kernel1'] as int,
            kernel2: json['kernel2'] as int
        );
      default:
        return Layer(
          imageUrl: 'assets/images/brain.png',
          type: json['type'] as String,
          id: json['id'] as int,
          activationFunction: json['activationFunction'] as String,
        );
    }
  }

  bool equals(Layer layer){
    return id == layer.id && type == layer.type && activationFunction == layer.activationFunction;
  }
}

class DenseLayer extends Layer{
  int numberOfNodes;

  DenseLayer({
    this.numberOfNodes,
    int id,
    String type,
    String activationFunction,
    String imageUrl
  }):super(
      id: id,
      type: type,
      activationFunction: activationFunction,
      imageUrl: imageUrl
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'numberOfNodes': numberOfNodes
    });
    return json;
  }
}

class ConvolutionalLayer extends Layer {
  int filter;
  int kernel1;
  int kernel2;

  ConvolutionalLayer({
    this.filter,
    this.kernel1,
    this.kernel2,
    int id,
    String type,
    String activationFunction,
    String imageUrl
  }):super(
    id: id,
    type: type,
    activationFunction: activationFunction,
    imageUrl: imageUrl
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'filter': filter,
      'kernel1': kernel1,
      'kernel2': kernel2
    });
    return json;
  }
}