import json

import numpy as np
import pandas as pd
import pickle
from sklearn import preprocessing, metrics
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier, MLPRegressor
from sklearn.preprocessing import MinMaxScaler, StandardScaler
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor

from data_files import file_extensions
from dirs import MODEL_DIR, get_data_dir
from data_server import DataServer
import os


def get_regression_scoring(y_test, y_pred):
    scoring = {}
    try:
        scoring['r2'] = \
            metrics.r2_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['explained_variance'] = \
            metrics.explained_variance_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['max_error'] = \
            metrics.max_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_mean_absolute_error'] = \
            metrics.mean_absolute_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_mean_squared_error'] = \
            metrics.mean_squared_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_root_mean_squared_error'] = \
            metrics.mean_squared_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_mean_squared_log_error'] = \
            metrics.mean_squared_log_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_median_absolute_error'] = \
            metrics.median_absolute_error(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_mean_poisson_deviance'] = \
            metrics.mean_poisson_deviance(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_mean_gamma_deviance'] = \
            metrics.mean_gamma_deviance(y_test, y_pred)
    except Exception:
        pass
    return scoring


def get_classification_scoring(y_test, y_pred):
    scoring = {}
    try:
        scoring['accuracy'] = \
            metrics.a
        metrics.ccuracy_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['balanced_accuracy'] = \
            metrics.balanced_accuracy_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['average_precision'] = \
            metrics.average_precision_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_brier_score'] = \
            metrics.brier_score_loss(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['f1'] = \
            metrics.f1_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['neg_log_loss'] = \
            metrics.log_loss(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['precision'] = \
            metrics.precision_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['recall'] = \
            metrics.recall_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['jaccard'] = \
            metrics.jaccard_score(y_test, y_pred)
    except Exception:
        pass
    try:
        scoring['roc_auc'] = \
            metrics.roc_auc_score(y_test, y_pred)
    except Exception:
        pass
    return scoring


def get_clustering_scoring(y, y_pred):
    scoring = {}
    if y is None:
        return scoring
    try:
        scoring['adjusted_mutual_info_score'] = \
            metrics.adjusted_mutual_info_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['adjusted_rand_score'] = \
            metrics.adjusted_rand_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['completeness_score'] = \
            metrics.completeness_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['fowlkes_mallows_score'] = \
            metrics.fowlkes_mallows_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['homogeneity_score'] = \
            metrics.homogeneity_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['mutual_info_score'] = \
            metrics.mutual_info_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['normalized_mutual_info_score'] = \
            metrics.normalized_mutual_info_score(y, y_pred)
    except Exception:
        pass
    try:
        scoring['v_measure_score'] = \
            metrics.v_measure_score(y, y_pred)
    except Exception:
        pass
    return scoring


def train(user_id: int,
          model_id: int,
          data_id: int,
          model,
          train_type: str,
          params: list,
          y_col: str,
          to_drop: list = None,
          test_size: float = 0.1,
          normalization_method: str = None,
          ):
    filename, file_type = get_data_dir(user_id=user_id, data_id=data_id)
    file_type = file_type[1:]
    if file_type in file_extensions['csv']:
        df = pd.read_csv(filename)
    elif file_type in file_extensions['json']:
        df = pd.read_json(filename, orient='split')
    elif file_type in file_extensions['excel']:
        # TODO: Make ability to handle multiple sheets
        excel = pd.ExcelFile(filename)
        df = pd.read_excel(filename, excel.sheet_names[0])
    else:
        raise Exception('Unsupported file type')
    columns = []
    for column in df:
        columns.append({
            'name': column,
            'type': df[column].dtype.__str__(),
            'null_count': int(df[column].isnull().sum())
        })

    to_drop = [] if to_drop is None else to_drop

    df = df.drop(columns=[col for col in to_drop if col in df])

    object_cols = []
    label_encoders = {}
    for column in df:
        if df[column].dtype == 'object':
            le = preprocessing.LabelEncoder()
            df[column] = le.fit_transform(df[column])
            object_cols.append(column)
            label_encoders[column] = le

    if not test_size or test_size < 0 or test_size >= 1:
        test_size = 0.2

    if y_col is not None:
        x = df.loc[:, df.columns != y_col]
        y = df[y_col]
    else:
        x = df
        y = None

    normalize_scaler = None
    if normalization_method == 'min_max':
        normalize_scaler = MinMaxScaler()
        normalize_scaler.fit(x)
    elif normalization_method == 'std':
        normalize_scaler = StandardScaler()
        normalize_scaler.fit(x)
    else:
        pass

    if train_type == 'cls' or train_type == 'reg':
        x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=test_size)


    dataset_info = {
        'id': data_id,
        'type': file_type,
        'columns': columns,
        'normalization_method': normalization_method
    }

    if normalize_scaler is None:
        if train_type == 'cls' or train_type == 'reg':
            model.fit(x_train, y_train)
            y_pred = model.predict(x_test)
        else:
            model.fit(x)
            y_pred = model.predict(x)
    else:
        if train_type == 'cls' or train_type == 'reg':
            model.fit(normalize_scaler.transform(x_train), y_train)
            y_pred = model.predict(normalize_scaler.transform(x_test))
        else:
            model.fit(normalize_scaler.transform(x))
            y_pred = model.predict(x)

    if train_type == 'cls':
        scoring = get_classification_scoring(y_test, y_pred)
    elif train_type == 'reg':
        scoring = get_regression_scoring(y_test, y_pred)
    else:
        scoring = get_clustering_scoring(y, y_pred)

    trained_model_file = open(os.path.join(MODEL_DIR, f'{user_id}', f'{model_id}.pickle'), 'wb')
    model_file_contents = {
        'model': model,
        'label_encoders': label_encoders,
        'normalize_scaler': normalize_scaler
    }
    pickle.dump(model_file_contents, trained_model_file)
    trained_model_file.close()

    model_info_contents = {
        'user_id': user_id,
        'model_id': model_id,
        'scoring': scoring,
        'params': params,
        'to_drop': to_drop,
        'y_col': y_col,
        'dataset_info': dataset_info
    }
    model_info_file = open(os.path.join(MODEL_DIR, f'{user_id}', f'{model_id}.json'), 'w')
    model_info_file.write(json.dumps(model_info_contents))
    model_info_file.close()

    print('Model trained and saved')
    print(DataServer.notify_server(model_id=model_id, status="done", extra=model_info_contents))


def train_linearreg(user_id: int,
                    data_id: int,
                    model_id: int,
                    to_drop: list,
                    y_col: str,
                    normalize: bool,
                    test_size: float,
                    fit_intercept: bool,
                    normalization_method=None):
    try:
        linearreg = LinearRegression(fit_intercept=fit_intercept, normalize=normalize)
        train(user_id, model_id, data_id, linearreg, 'reg',
              [
                {
                    'name': 'fit_intercept',
                    'humanName': 'Fit Intercept',
                    'value': fit_intercept
                },
                {
                    'name': 'normalize',
                    'humanName': 'Normalize',
                    'value': normalize
                }
              ],
              y_col, to_drop, test_size, normalization_method,)

    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))


def train_knn(user_id: int,
              data_id: int,
              model_id: int,
              to_drop: list,
              y_col: str,
              test_size: float,
              n_neighbors: int,
              weights,
              algorithm: str,
              train_type: str,
              normalization_method=None):

    try:
        if train_type == 'cls':
            knn = KNeighborsClassifier(n_neighbors=n_neighbors, weights=weights, algorithm=algorithm)
        else:
            knn = KNeighborsRegressor(n_neighbors=n_neighbors, weights=weights, algorithm=algorithm)

        train(user_id, model_id, data_id, knn, train_type,
              [
                {
                    'name': 'n_neighbors',
                    'humanName': 'Number of Neighbors',
                    'value': n_neighbors,
                },
                {
                    'name': 'weights',
                    'humanName': 'Weights',
                    'value': weights,
                },
                {
                    'name': 'algorithm',
                    'humanName': 'Algorithm',
                    'value': algorithm,
                },
              ],
              y_col, to_drop, test_size, normalization_method)
    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))


def train_decisiontree(user_id: int,
                       data_id: int,
                       model_id: int,
                       to_drop: list,
                       y_col: str,
                       test_size: float,
                       max_depth: int,
                       max_features,
                       criterion: str,
                       splitter: str,
                       train_type: str,
                       normalization_method=None):

    try:
        if train_type == 'cls':
            decision_tree = DecisionTreeClassifier(criterion=criterion, splitter=splitter,
                                                   max_depth=max_depth, max_features=max_features)
        else:
            decision_tree = DecisionTreeRegressor(criterion=criterion, splitter=splitter,
                                                  max_depth=max_depth, max_features=max_features)
        train(user_id, model_id, data_id, decision_tree, train_type,
              [
                {
                    'name': 'max_depth',
                    'humanName': 'Maximum Depth',
                    'value': max_depth,
                },
                {
                    'name': 'max_features',
                    'humanName': 'Maximum Features',
                    'value': max_features,
                },
                {
                    'name': 'criterion',
                    'humanName': 'Criterion',
                    'value': criterion,
                },
                {
                    'name': 'splitter',
                    'humanName': 'Splitter',
                    'value': splitter,
                },
              ],
              y_col, to_drop, test_size, normalization_method)
    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))


def train_randomforest(user_id: int,
                       data_id: int,
                       model_id: int,
                       to_drop: list,
                       y_col: str,
                       test_size: float,
                       n_estimators: int,
                       max_depth: int,
                       max_features,
                       criterion: str,
                       bootstrap: bool,
                       ccp_alpha: float,
                       train_type: str,
                       class_weight: str = None,
                       normalization_method=None):

    try:
        if train_type == 'cls':
            random_forest = RandomForestClassifier(n_estimators=n_estimators, max_depth=max_depth,
                                                   max_features=max_features, criterion=criterion, bootstrap=bootstrap,
                                                   class_weight=class_weight, ccp_alpha=ccp_alpha)
        else:
            random_forest = RandomForestRegressor(n_estimators=n_estimators, max_depth=max_depth,
                                                  max_features=max_features, criterion=criterion, bootstrap=bootstrap,
                                                  ccp_alpha=ccp_alpha)
        train(user_id, model_id, data_id, random_forest, train_type,
              [
                {
                    'name': 'n_estimators',
                    'humanName': 'Number of estimators',
                    'value': n_estimators,
                },
                {
                    'name': 'max_depth',
                    'humanName': 'Maximum depth',
                    'value': max_depth,
                },
                {
                    'name': 'max_features',
                    'humanName': 'Maximum features',
                    'value': max_features,
                },
                {
                    'name': 'criterion',
                    'humanName': 'Criterion',
                    'value': criterion,
                },
                {
                    'name': 'bootstrap',
                    'humanName': 'Bootstrap',
                    'value': bootstrap,
                },
                {
                    'name': 'ccp_alpha',
                    'humanName': 'Cost Complexity Parameter',
                    'value': ccp_alpha,
                },
              ] + (
                [{
                    'name': 'class_weight',
                    'humanName': 'Class Weight',
                    'value': class_weight,
                }] if train_type == 'cls' else []
              ),
              y_col, to_drop, test_size, normalization_method)
    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))


def train_mpl(user_id: int,
              data_id: int,
              model_id: int,
              to_drop: list,
              y_col: str,
              test_size: float,
              hidden_layer_sizes: list,
              max_iter: int,
              activation: str,
              solver: str,
              learning_rate: str,
              learning_rate_init: float,
              tol: float,
              train_type: str,
              normalization_method):
    try:
        hidden_layer_sizes = tuple(hidden_layer_sizes)
        if train_type == 'cls':
            mpl = MLPClassifier(hidden_layer_sizes=hidden_layer_sizes, max_iter=max_iter, activation=activation,
                                solver=solver, learning_rate=learning_rate, learning_rate_init=learning_rate_init,
                                tol=tol)
        else:
            mpl = MLPRegressor(hidden_layer_sizes=hidden_layer_sizes, max_iter=max_iter, activation=activation,
                               solver=solver, learning_rate=learning_rate, learning_rate_init=learning_rate_init,
                               tol=tol)
        train(user_id, model_id, data_id, mpl, train_type,
              [
                {
                    'name': 'hidden_layer_sizes',
                    'humanName': 'Hidden Layer Sizes',
                    'value': hidden_layer_sizes,
                },
                {
                    'name': 'max_iter',
                    'humanName': 'Maximum Iterations',
                    'value': max_iter,
                },
                {
                    'name': 'activation',
                    'humanName': 'Activation Function',
                    'value': activation,
                },
                {
                    'name': 'solver',
                    'humanName': 'Solver',
                    'value': solver,
                },
                {
                    'name': 'learning_rate',
                    'humanName': 'Learning Rate',
                    'value': learning_rate,
                },
                {
                    'name': 'learning_rate_init',
                    'humanName': 'Learning Rate Initialization',
                    'value': learning_rate_init,
                },
                {
                    'name': 'tol',
                    'humanName': 'Tolerance',
                    'value': tol,
                }
              ],
              y_col, to_drop, test_size, normalization_method)

    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))


def train_kmeans(user_id: int,
                 data_id: int,
                 model_id: int,
                 to_drop: list,
                 y_col: str,
                 n_clusters: int,
                 max_iter: int,
                 tol: float,
                 algorithm: str,
                 normalization_method=None):

    try:
        kmeans = KMeans(n_clusters=n_clusters, max_iter=max_iter, tol=tol, algorithm=algorithm)

        train(user_id, model_id, data_id, kmeans, 'clu',
              [
                {
                    'name': 'n_clusters',
                    'humanName': 'Number of Clusters',
                    'value': n_clusters,
                },
                {
                    'name': 'max_iter',
                    'humanName': 'Maximum Iterations',
                    'value': max_iter,
                },
                {
                    'name': 'algorithm',
                    'humanName': 'Algorithm',
                    'value': algorithm,
                },
                {
                    'name': 'tol',
                    'humanName': 'Tolerance',
                    'value': tol,
                },
              ],
              y_col, to_drop, 0, normalization_method)
    except Exception as e:
        print(e.__str__())
        print(DataServer.notify_server(model_id=model_id, status="fail", extra={'error': e.__str__()}))
