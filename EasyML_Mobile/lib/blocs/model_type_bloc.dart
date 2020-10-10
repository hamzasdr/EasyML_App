
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/K_nearest_neighbor_model.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/decision_tree_classifier_model.dart';
import 'package:prototyoe_project_app/models/decision_tree_regressor_model.dart';
import 'package:prototyoe_project_app/models/kmeans.dart';
import 'package:prototyoe_project_app/models/linear_reg_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/models/random_forest_classifier_model.dart';
import 'package:prototyoe_project_app/models/random_forest_regressor_model.dart';
import 'package:prototyoe_project_app/archive/conv_nn_page.dart';
import 'package:prototyoe_project_app/archive/linear_reg_page.dart';
import 'package:prototyoe_project_app/archive/Random_Forest_clas_page.dart';
import 'package:prototyoe_project_app/archive/Random_Forest_reg_page.dart';
import 'package:prototyoe_project_app/archive/Decision_Tree_clas_page.dart';
import 'package:prototyoe_project_app/archive/Decision_Tree_reg_page.dart';
import 'package:prototyoe_project_app/archive/K_nearest_page.dart';
import 'package:prototyoe_project_app/pages/model_page.dart';
import 'package:prototyoe_project_app/widgets/model_params/knn_params.dart';

/*
* This file contains the class that is responsible for managing the 'modelTypes' array
* This is not needed for this type of data because it's static, but it's just to show how to use it
* The MaterialApp widget at the main.dart is surrounded by a MultiProvider widget which is used to add data providers to children widgets
*   * Since the child widget is the whole app, this provider is global and can be accessed from anywhere in the app
* The 'providers' argument contains a list of arguments for each provider. Inside it, the ChangeNotifierProvider provider is defined and linked (using 'value' property) to an object of this Bloc class
* Next, the CreateModelCarousel requests the provider to give it the instance of the ModelTypeBloc from the widget tree, which was defined at the MaterialApp widget
* Any data accessed by the CreateModelCarousel is from the Bloc, so updates to the Bloc data directly get re-rendered
*
* */

class ModelTypeBloc extends ChangeNotifier{
  static final List<ModelType> _modelTypes = [
    ModelType(
        name: "Linear Regression",
        programmaticName: "linearreg",
        shortDescription: "This is a random description of the thing",
        longDescription: "LinearRegression fits a linear model to minimize the residual sum of squares between the observed targets in the dataset, and the targets predicted by the linear approximation. \n\n"
        "Main Advantages :\n\n"
        "• Easy to interpret and very efficient to train.\n\n"
        "• Performs well when the dataset is linearly separable.\n\n\n"
        "Main Disadvantages :\n\n"
        "• Prone to noise and overfitting: If the number of observations are lesser than the number of features, Linear Regression should not be used.\n\n"
        "• It over-simplifies real world problems by assuming linear relationship among the variables.\n\n"
        ,
        imageUrl: "assets/images/linearreg.png",
        createModel: ({String imageUrl, String name}) => LinearRegressionModel(
            name: name,
            type: modelTypeMap['linearreg']
        ),
        category: ModelCategory.REGRESSION
    ),
    ModelType(
        name: "Neural Network",
        programmaticName: "mpl_cls",
        shortDescription: "This is a random description of the thing",
        longDescription: "Multi-layer Perceptron Feed-forward Neural Network is a supervised learning algorithm that learns a function by training on a dataset."
            "It can learn a non-linear function approximator for either classification or regression. "
            "Between the input and the output layer, there can be one or more non-linear layers, called hidden layers. "
            "This model implements a multi-layer perceptron (MLP) algorithm that trains using Backpropagation.\n\n"
            "Main Advantages :\n\n"
            "• Ability to work with incomplete knowledge.\n\n"
            "• Has fault tolerance.\n\n\n"
            "Main Disadvantages :\n\n"
            "• Unexplained behavior of the network: When it produces a probing solution, it does not give a clue as to why and how.\n\n"
            "• Determination of proper network structure: There is no specific rule for determining the structure of neural networks.\n\n"
        ,
        imageUrl: "assets/images/mpl.png",
        createModel: ({String imageUrl, String name}) => MultilayerPerceptronModel(
            name: name,
            type: modelTypeMap['mpl_cls']
        ),
        category: ModelCategory.CLASSIFICATION
    ),
    ModelType(
        name: "Neural Network",
        programmaticName: "mpl_reg",
        shortDescription: "This is a random description of the thing",
        longDescription: "Multi-layer Perceptron Feed-forward Neural Network is a supervised learning algorithm that learns a function by training on a dataset."
        "It can learn a non-linear function approximator for either classification or regression. "
        "Between the input and the output layer, there can be one or more non-linear layers, called hidden layers. "
        "This model implements a multi-layer perceptron (MLP) algorithm that trains using Backpropagation.\n\n"
            "Main Advantages :\n\n"
            "• Ability to work with incomplete knowledge.\n\n"
            "• Having fault tolerance.\n\n\n"
            "Main Disadvantages :\n\n"
            "• Unexplained behavior of the network: When it produces a probing solution, it does not give a clue as to why and how.\n\n"
            "• Determination of proper network structure: There is no specific rule for determining the structure of artificial neural networks.\n\n"
        ,
        imageUrl: "assets/images/mpl.png",
        createModel: ({String imageUrl, String name}) => MultilayerPerceptronModel(
            name: name,
            type: modelTypeMap['mpl_reg']
        ),
        category: ModelCategory.REGRESSION
    ),
    ModelType(
        name: "K-Nearest Neighbors",
        programmaticName: "knn_cls",
        shortDescription: "This is a random description of the thing",
        longDescription:
        "K-Nearest Neighbors is a simple supervised classification algorithm we can use to assign a class to new data point. "
        "The principle behind nearest neighbor methods is to find a predefined number of training samples closest in distance to the new point, and predict the label from these."
        "KNN keeps all the training data to make future predictions by computing the similarity between an input sample and each training instance.\n\n"
            "Main Advantages :\n\n"
            "• If 'K' value is high, the model is robust against noise.\n\n"
            "• Can learn non-linear boundary.\n\n\n"
            "Main Disadvantages :\n\n"
            "• Needs normalization.\n\n"
            "• If 'K' value is low, the model is susceptible to noise.\n\n"
            "• Does not work well with high dimensions.\n\n"
        ,
        imageUrl: "assets/images/knn.png",
        createModel: ({String imageUrl, String name}) => KNearestNeighborsClassifierModel(
          name: name,
          type: modelTypeMap['knn_cls']
        ),
        category: ModelCategory.CLASSIFICATION
    ),
    ModelType(
        name: "K-Nearest Neighbors",
        programmaticName: "knn_reg",
        shortDescription: "This is a random description of the thing",
        longDescription:
        "K-Nearest Neighbors is originally a classification algorithm, but it also can be used for regression "
        "The principle behind nearest neighbor methods is to find a predefined number of training samples closest in distance to the new point, and predict the label from these."
        "KNN keeps all the training data to make future predictions by computing the similarity between an input sample and each training instance."
        "The label assigned to a query point is computed based on the mean of the labels of its nearest neighbors.\n\n"
            "Main Advantages :\n\n"
            "• if 'K' value is high, the model is robust against noise.\n\n"
            "• Can learn non-linear boundary.\n\n\n"
            "Main Disadvantages :\n\n"
            "• Needs normalization.\n\n"
            "• If 'K' value is low, the model is susceptible to noise.\n\n"
            "• Does not work well with high dimensions.\n\n"
        ,
        imageUrl: "assets/images/knn.png",
        createModel: ({String imageUrl, String name}) => KNearestNeighborsRegressorModel(
            name: name,
            type: modelTypeMap['knn_reg']
        ),
        category: ModelCategory.REGRESSION
    ),
    ModelType(
        name: "Decision Tree",
        programmaticName: "decisiontree_reg",
        shortDescription: "This is a random description of the thing",
        longDescription: "Decision Trees are a supervised learning method used for classification and regression. "
            "The goal is to create a model that predicts the value of a target variable by learning simple decision rules inferred from the data features. "
            "For this model Decision Trees will be applied to regression problems."
            "The deeper the tree, the more complex the decision rules and the fitter the model.\n\n"
            "Main Advantages :\n\n"
            "• Performs better than other algorithms on non-normalized data.\n\n"
            "• Missing values in the data does not affect the process of building decision tree to an extent.\n\n\n"
            "Main Disadvantages :\n\n"
            "• A small change in the data can cause a large change in the structure.\n\n"
            "• Decision Tree algorithm is inadequate for applying regression.\n\n"
            "• Training is relatively expensive as complexity and time taken is often high.\n\n"
        ,
        imageUrl: "assets/images/decisiontree.png",
        createModel: ({String imageUrl, String name}) => DecisionTreeRegressorModel(
            name: name,
            type: modelTypeMap['decisiontree_reg']
        ),
        category: ModelCategory.REGRESSION
    ),
    ModelType(
        name: "Decision Tree",
        programmaticName: "decisiontree_cls",
        shortDescription: "This is a random description of the thing",
        longDescription: "Decision Trees (DTs) are a supervised learning method used for classification and regression."
        "The goal is to create a model that predicts the value of a target variable by learning simple decision rules inferred from the data features. "
            "For this model Decision Trees will be used to perform multi-class classification on a dataset. "
            "The deeper the tree, the more complex the decision rules and the fitter the model.\n\n"
            "Main Advantages :\n\n"
            "• Performs better than other algorithms on non-normalized data.\n\n"
            "• Missing values in the data also does NOT affect the process of building decision tree to an extent.\n\n\n"
            "Main Disadvantages :\n\n"
            "• A small change in the data can cause a large change in the structure.\n\n"
            "• Training is relatively expensive as complexity and time taken is often high.\n\n"
        ,
        imageUrl: "assets/images/decisiontree.png",
        createModel: ({String imageUrl, String name}) => DecisionTreeClassifierModel(
            name: name,
            type: modelTypeMap['decisiontree_cls']
        ),
        category: ModelCategory.CLASSIFICATION
    ),
    ModelType(
        name: "Random Forest",
        programmaticName: "randomforest_reg",
        shortDescription: "This is a random description of the thing",
        longDescription: "A random forest is a meta estimator that fits a number of decision trees on various sub-samples of the dataset and uses averaging to improve the predictive accuracy and control over-fitting.\n\n"
            "Main Advantages :\n\n"
            "• Performs better than other algorithms on non-normalized data.\n\n"
            "• Can automatically handle missing values.\n\n"
            "• Usually robust to noise .\n\n"
            "• Handles non-linear parameters efficiently.\n\n\n"
            "Main Disadvantage :\n\n"
            "• Training is relatively expensive as complexity and time taken is often high.\n\n"
        ,
        imageUrl: "assets/images/randomforest.png",
        createModel: ({String imageUrl, String name}) => RandomForestRegressorModel(
            name: name,
            type: modelTypeMap['randomforest_reg']
        ),
        category: ModelCategory.REGRESSION
    ),
    ModelType(
        name: "Random Forest",
        programmaticName: "randomforest_cls",
        shortDescription: "This is a random description of the thing",
        longDescription: "A random forest is a meta estimator that fits a number of decision tree classifiers on various sub-samples of the dataset and uses averaging to improve the predictive accuracy and control over-fitting.\n\n"
            "Main Advantages :\n\n"
            "• Performs better than other algorithms on non-normalized data.\n\n"
            "• Can automatically handle missing values.\n\n"
            "• Usually robust to noise .\n\n"
            "• Handles non-linear parameters efficiently.\n\n\n"
            "Main Disadvantage :\n\n"
            "• Training is relatively expensive as complexity and time taken is often high.\n\n"
        ,
        imageUrl: "assets/images/randomforest.png",
        createModel: ({String imageUrl, String name}) => RandomForestClassifierModel(
            name: name,
            type: modelTypeMap['randomforest_cls']
        ),
        category: ModelCategory.CLASSIFICATION
    ),
    ModelType(
      name: "K Means",
      programmaticName: "kmeans",
      shortDescription: "This is a random description of the thing",
      longDescription: "The KMeans algorithm clusters data by trying to separate samples in n groups of equal variance, minimizing a criterion known as the inertia or within-cluster sum-of-squares. "
      "Inertia can be recognized as a measure of how internally coherent clusters are. "
      "This algorithm requires the number of clusters to be specified. It scales well to large number of samples and has been used across a large range of application areas in many different fields.\n\n"
          "Main Advantages :\n\n"
          "• Scales to large data sets.\n\n"
          "• Guarantees convergence.\n\n"
          "• Easily adapts to new examples.\n\n"
          "• Generalizes to clusters of different shapes and sizes, such as elliptical clusters.\n\n\n"
          "Main Disadvantages :\n\n"
          "• Has trouble clustering data where clusters are of varying sizes and density.\n"
          "• To cluster such data, you need to generalize k-means as described in the advantages section.\n\n"
          "• Does not perform well with large number of dimensions.\n\n"
        ,
      imageUrl: "assets/images/kmeans.png",
      createModel: ({String imageUrl, String name}) => KMeansModel(
          name: name,
          type: modelTypeMap['kmeans']
      ),
      category: ModelCategory.CLUSTERING
    )
  ];

  static final Map<String, ModelType> modelTypeMap = Map.fromIterable(_modelTypes, key: (e)=>e.programmaticName, value: (e)=>e);

  List<ModelType> get modelTypes => _modelTypes;

  void notify(){
    notifyListeners();
  }
//  set modelTypes(List<ModelType> modelTypes){
//    this._modelTypes = modelTypes;
//    notifyListeners();
//  }

}