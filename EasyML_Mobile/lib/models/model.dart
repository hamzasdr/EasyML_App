
import 'dart:convert';

import 'package:flutter_highlight/themes/default.dart';
import 'package:prototyoe_project_app/blocs/model_type_bloc.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/K_nearest_neighbor_model.dart';
import 'package:prototyoe_project_app/models/decision_tree_regressor_model.dart';
import 'package:prototyoe_project_app/models/decision_tree_classifier_model.dart';
import 'package:prototyoe_project_app/models/random_forest_classifier_model.dart';
import 'package:prototyoe_project_app/models/random_forest_regressor_model.dart';
import 'package:prototyoe_project_app/models/linear_reg_model.dart';
import 'package:meta/meta.dart';

import 'kmeans.dart';
import 'layer_type.dart';
import 'model_type.dart';
class Model{

  int id;
  String name;
  ModelType type;
  bool beingTrained;
  bool synced;
  Map<String, dynamic> info;

  Model({
    this.id = -1,
    this.name,
    this.type,
    this.beingTrained = false,
    this.synced = false,
    this.info
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.programmaticName,
    'being_trained': beingTrained,
    'synced': synced,
    'info': info
  };

  factory Model.fromJson(Map<String, dynamic> json,{bool synced = false}){
    ModelType type = ModelTypeBloc.modelTypeMap[json['type'] as String];
    switch(type.programmaticName){
      case 'mpl_cls':
      case 'mpl_reg':
        return MultilayerPerceptronModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          hiddenLayerSizes: (jsonDecode((json['hidden_layer_sizes']??"[100,]")) as List<dynamic>).cast<int>(),
          maxIter: json['max_iter'],
          activation: json['activation'],
          solver: json['solver'],
          learningRate: json['learning_rate'],
          learningRateInit: json['learning_rate_init'],
          tol: json['tol']
        );
      case 'linearreg':
        return LinearRegressionModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          fitIntercept: json['fit_intercept'] as bool,
          normalize: json['normalize'] as bool,
        );
      case 'knn_cls':
        return KNearestNeighborsClassifierModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          nNeighbors: json['n_neighbors'] as int,
          weights: json['weights'] as dynamic,
          algorithm: json['algorithm'] as String,
        );
      case 'knn_reg':
        return KNearestNeighborsRegressorModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          nNeighbors: json['n_neighbors'] as int,
          weights: json['weights'] as dynamic,
          algorithm: json['algorithm'] as String,
        );
      case 'decisiontree_reg':
        var maxFeatures;
        if(json['max_features'] is String)
          maxFeatures = int.tryParse(json['max_features']) ?? double.tryParse(json['max_features']) ?? json['max_features'];
        else
          maxFeatures = json['max_features'];
        return DecisionTreeRegressorModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          criterion: json['criterion'] as String,
          splitter: json['splitter'] as String,
          maxDepth: json['max_depth'] as int,
          maxFeatures: maxFeatures,
        );
      case 'decisiontree_cls':
        var maxFeatures;
        if(json['max_features'] is String)
          maxFeatures = int.tryParse(json['max_features']) ?? double.tryParse(json['max_features']) ?? json['max_features'];
        else
          maxFeatures = json['max_features'];
        return DecisionTreeClassifierModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          criterion: json['criterion'] as String,
          splitter: json['splitter'] as String,
          maxDepth: json['max_depth'] as int,
          maxFeatures: maxFeatures,
        );
      case 'randomforest_reg':
        var maxFeatures;
        if(json['max_features'] is String)
          maxFeatures = int.tryParse(json['max_features']) ?? double.tryParse(json['max_features']) ?? json['max_features'];
        else
          maxFeatures = json['max_features'];
        return RandomForestRegressorModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          nEstimators: json['n_estimators'] as int,
          criterion: json['criterion'] as String,
          maxDepth: json['max_depth'] as int,
          maxFeatures: maxFeatures,
          ccpAlpha: json['ccp_alpha'] as double,
          bootstrap: json['bootstrap'] as bool,
          verbose: json['verbose'] as int,
        );
      case 'randomforest_cls':
        var maxFeatures;
        if(json['max_features'] is String)
          maxFeatures = int.tryParse(json['max_features']) ?? double.tryParse(json['max_features']) ?? json['max_features'];
        else
          maxFeatures = json['max_features'];
        return RandomForestClassifierModel(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
          nEstimators: json['n_estimators'] as int,
          criterion: json['criterion'] as String,
          maxDepth: json['max_depth'] as int,
          maxFeatures: maxFeatures,
          ccpAlpha: json['ccp_alpha'] as double,
          bootstrap: json['bootstrap'] as bool,
          classWeight: json['class_weight'] as String
        );
      case 'kmeans':
        return KMeansModel(
            id: json['id'] as int,
            name: json['name'] as String,
            type: type,
            beingTrained: json['being_trained'],
            synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
            info: json['info'],
            algorithm: json['algorithm'],
            maxIter: json['max_iter'],
            nClusters: json['n_clusters'],
            tol: json['tol']
        );
      default:
        return Model(
          id: json['id'] as int,
          name: json['name'] as String,
          type: type,
          beingTrained: json['being_trained'],
          synced: (!synced && json.containsKey('synced') ? json['synced'] : synced),
          info: json['info'],
        );
    }
  }

  bool equals(Model model) {
    return id == model.id && name == model.name && type == model.type;
  }

  List<List<String>> get codeBlocks{
    return [];
  }

  String get code{
    String code = '';
    for (List<String> block in codeBlocks) {
      for (String line in block) {
        code+=line;
      }
    }
    return code;
  }

  @protected
  List<List<String>> generateCodeBlocks(List<String> libraries, List<String> parameters, List<String> creation){
    return [
      [
        '# Import needed libraries\n',
        '# Make sure you install the libraries if you don\'t have them installed, the pip command for installing each library will be above its import line(s)\n',
        '\n',
        '# pip install numpy\n',
        'import numpy as np\n',
        '\n',
        '# pip install pandas\n',
        'import pandas as pd\n',
        '\n',
        '# this comes with the standard python libraries, no need to install\n',
        'import pickle\n',
        '\n',
        '# pip install scikit-learn\n',
        'from sklearn import preprocessing\n',
        'from sklearn.preprocessing import MinMaxScaler, StandardScaler\n',
        'from sklearn.model_selection import train_test_split\n',
      ]
      + libraries +
      [
        'import sklearn.metrics as metrics\n',
        '\n',
      ],
      [
        '\n',
        '# put the data set file path between the quotes\n',
        '# example: dataset_file = "C:/Documents/my dataset.csv"\n',
        'dataset_file = ""\n',
        '\n',
        'df = pd.read_csv(dataset_file)\n',
      ],
      [
        '\n',
        '# put the names of the columns that you don\'t want to use for training here\n',
        '# example: to_drop = ["id", "name"]\n',
        'to_drop = []\n',
        '\n',
        'df = df.drop(columns=[col for col in to_drop if col in df])\n',
      ],
      [
        '\n',
        type.category == ModelCategory.CLUSTERING ?
        '# the label is not used for training, only for scoring\n':
        '# put the name of your target column to predict between quotes\n',
        '# example: label = "sales"\n',
        'label = ""\n',
      ],
      [
        '\n',
        '# this will transform string columns into numbers training must be done with numbers\n',
        '# the encoders are saved because the same ones need to be used in prediction\n',
        'label_encoders = {}\n',
        'for column in df:\n',
        '    if df[column].dtype == "object":\n',
        '        le = preprocessing.LabelEncoder()\n',
        '        df[column] = le.fit_transform(df[column])\n',
        '        label_encoders[column] = le\n',
        '\n',
      ],
      [
        '\n',
        '# Do any other operations you want to preform on the data set here\n',
        '\n',
      ],
      type.category != ModelCategory.CLUSTERING ?
      [
        '\n',
        '# How much of the data set will you use for testing?\n',
        '# 0.2 means 80% will be used for training, and 20% will be used for testing the trained model\n',
        '# valid values are between 0 and 1\n',
        '# recommended between 0.1 and 0.35\n',
        'test_size = 0.2\n',
      ] :
      [],
      [
        '\n',
        '# splitting the data into input (x) and output (y)\n',
        'x = df.loc[:, df.columns != label]\n',
        'y = df[label]\n',
      ],
      type.category != ModelCategory.CLUSTERING ?
      [
        '\n',
        '# splitting the data into training and testing data\n',
        'x_train, x_test, y_train, y_test = \\\n',
        ' train_test_split(x, y, test_size=test_size)\n',
      ] :
      [
        '# in clustering the algorithm doesn\'t use the label for training\n',
        '# so no need to split the data for testing a training\n',
        '# the model can be tested used the original label\n'
      ],
      [
        '\n',
        '# data normalization \n',
        '# normalization is essencial especially if the features in your data span different ranges \n',
        '# its to make sure that all features affect the predictions equally \n',
        '# the normalization scaler is set to None which will not perform normalization\n',
        '# Change it to MinMaxScaler() if you want to perform minimum-maximum normalization\n',
        '# Change it to StandardScaler() if you want to perform mean-standard deviation normalization\n',
        'normalization_scaler = None\n',
        'if normalization_scaler is not None:\n',
        '    normalization_scaler.fit(x)\n',
        type.category != ModelCategory.CLUSTERING ?
        '    x_train = normalization_scaler.transform(x_train)\n':
        '    x = normalization_scaler.transform(x)\n',
        type.category != ModelCategory.CLUSTERING ?
        '    x_test = normalization_scaler.transform(x_test)\n' : '',
        '\n',
      ],

      [
        '\n',
        '# the model parameters you specified earlier\n'
      ] + parameters,
      [
        '\n',
        '# create the model to train\n'
      ] + creation,

      [
        '\n',
        '# train the model\n',
        type.category != ModelCategory.CLUSTERING ? 'model.fit(x_train, y_train)\n' : 'model.fit(x)',
      ],
      type.category != ModelCategory.CLUSTERING ?
      [
        '\n',
        '# use the test data to predict y from x\n',
        '# this is to measure the accuracy of the model\n',
        'y_pred = model.predict(x_test)\n',
      ]:
      [
        '\n',
        '# use the clustered data to predict the label\n',
        '# this is to measure the accuracy of the model\n',
        '# this can be done because the clustering algorithm doesn\'t use labels\n',
        'y_pred = model.predict(x)\n',
      ],
      [
        '\n',
        '# the following lines of code are the scores that identify how good the model actually is\n',
        'scoring = {}\n',
      ] + _getScoring(type.category),
      [
        '\n',
        '# Print the scoring for the model\n',
        'for key in scoring:\n',
        '    print(f"{key}: {scoring[key]}")\n',
        '\n',
      ],
      [
        '\n',
        '# Do any other operations you want to preform on the trained model here\n',
        '\n',
      ],
      [
        '\n',
        '# saving the model to a file, put the file path that you want for the model between the quotes and make sure it ends with the \'.pickle\' extension\n',
        '# example: model_file = "C:/Documents/my trained model.pickle"\n',
        'model_file = ""\n',
        '\n',
        '# the saved model includes saving all the label encoders and the normalization scaler in a Python dictionary\n',
        'model_data = {\n',
        '    "model": model,\n',
        '    "label_encoders": label_encoders,\n',
        '    "normalization_scaler": normalization_scaler\n',
        '}\n',
        'pickle.dump(model, open(model_file, "wb"))\n',
        '\n',
      ]
    ];
  }

  static List<String> _getScoring(ModelCategory category){
    switch(category){
      case ModelCategory.CLASSIFICATION:
        return _classificationScoring;
        break;
      case ModelCategory.REGRESSION:
        return _regressionScoring;
        break;
      case ModelCategory.CLUSTERING:
        return _clusteringScoring;
        break;
      default:
        return [];
    }
  }
  static const List<String> _regressionScoring = const [
      'try:\n',
      '    scoring["explained_variance"] = \\\n',
      '    metrics.explained_variance_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["max_error"] = \\\n',
      '    metrics.max_error(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_mean_absolute_error"] = \\\n',
      '    metrics.mean_absolute_error(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_mean_squared_error"] = \\\n',
      '    metrics.mean_squared_error(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_mean_squared_log_error"] = \\\n',
      '    metrics.mean_squared_log_error(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_median_absolute_error"] = \\\n',
      '    metrics.median_absolute_error(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["r2"] = \\\n',
      '    metrics.r2_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_mean_poisson_deviance"] = \\\n',
      '    metrics.mean_poisson_deviance(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_mean_gamma_deviance"] = \\\n',
      '    metrics.mean_gamma_deviance(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
    ];
  static const List<String> _classificationScoring = const [
      'try:\n',
      '    scoring["accuracy"] = \\\n',
      '    metrics.accuracy_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["balanced_accuracy"] = \\\n',
      '    metrics.balanced_accuracy_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["average_precision"] = \\\n',
      '    metrics.average_precision_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_brier_score"] = \\\n',
      '    metrics.brier_score_loss(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["f1"] = \\\n',
      '    metrics.f1_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["neg_log_loss"] = \\\n',
      '    metrics.log_loss(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["precision"] = \\\n',
      '    metrics.precision_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["recall"] = \\\n',
      '    metrics.recall_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["jaccard"] = \\\n',
      '    metrics.jaccard_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'try:\n',
      '    scoring["roc_auc"] = \\\n',
      '    metrics.roc_auc_score(y_test, y_pred)\n',
      'except Exception:\n',
      '    pass\n',
      'return scoring\n',
    ];

  static const List<String> _clusteringScoring = const [
    'try:\n',
    '    scoring["adjusted_mutual_info_score"] = \\\n',
    '    metrics.adjusted_mutual_info_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["adjusted_rand_score"] = \\\n',
    '    metrics.adjusted_rand_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["completeness_score"] = \\\n',
    '    metrics.completeness_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["fowlkes_mallows_score"] = \\\n',
    '    metrics.fowlkes_mallows_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["homogeneity_score"] = \\\n',
    '    metrics.homogeneity_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["mutual_info_score"] = \\\n',
    '    metrics.mutual_info_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["normalized_mutual_info_score"] = \\\n',
    '    metrics.normalized_mutual_info_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
    'try:\n',
    '    scoring["v_measure_score"] = \\\n',
    '    metrics.v_measure_score(y, y_pred)\n',
    'except Exception:\n',
    '    pass\n',
  ];


}