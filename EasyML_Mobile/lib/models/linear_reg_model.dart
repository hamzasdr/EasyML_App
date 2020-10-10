import 'model.dart';
import 'model_type.dart';

class LinearRegressionModel extends Model{

  String y_colm;
  List<String> to_drop = [];

  bool fitIntercept;
  bool normalize;
  // bool copy_x;
  // int n_jobs;

  LinearRegressionModel({
    this.fitIntercept = true,
    this.normalize = false,
    // this.copy_x = true,
    // this.n_jobs = 1,
    int id,
    String name,
    ModelType type,
    bool beingTrained = false,
    bool synced = false,
    Map<String, dynamic> info,
  }):super(
      id: id,
      name: name,
      type: type,
      beingTrained: beingTrained,
      synced: synced,
      info: info
  );

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'fit_intercept': fitIntercept,
      'normalize': normalize,
      // 'y_colm': y_colm,
      // 'to_drop':to_drop,
    });
    return json;
  }

  @override
  bool equals(Model model){
    if(!(model is LinearRegressionModel))
      return false;
    LinearRegressionModel _model = model as LinearRegressionModel;

    return super.equals(_model) && fitIntercept == _model.fitIntercept && normalize == _model.normalize;
  }

  static const List<String> libraries = const [
    'from sklearn.linear_model import LinearRegression\n',
  ];
  static const List<String> creation = const [
    'model = LinearRegression(fit_intercept=fit_intercept,\n',
    '                         normalize=normalize)\n',
  ];

  @override
  List<List<String>> get codeBlocks{
    List<String> parameters = [
      'fit_intercept = ${fitIntercept ? 'True' : 'False'}\n',
      'normalize = ${normalize ? 'True' : 'False'}\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }
}
