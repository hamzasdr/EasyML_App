import os

from data_files import file_extensions
from dirs import DATA_DIR
from train import train_linearreg, train_knn, train_decisiontree, train_randomforest, \
    train_mpl, train_kmeans
import pandas as pd

models = {
    'linearreg': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': (list, str)
        },
        'optional': {
            'args': ('normalization_method', 'fit_intercept', 'normalize', 'test_size'),
            'default_values': (None, True, False, 0.1),
            'types': (str, bool, bool, float)
        },
        'function': train_linearreg
    },

    'knn_cls': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'n_neighbors', 'weights', 'algorithm'),
            'default_values': (None, 0.1, 5, 'uniform', 'auto'),
            'types': (str, float, int, str, str)
        },
        'type': 'cls',
        'function': train_knn
    },

    'randomforest_cls': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'n_estimators', 'max_depth', 'max_features', 'criterion', 'bootstrap',
                     'class_weight', 'ccp_alpha'),
            'default_values': (None, 0.1, 100, None, "auto", "gini", True,
                               "balanced", 0.0),
            'types': (str, float, int, int, (int, float, str), str, bool,
                      str, float)
        },
        'type': 'cls',
        'function': train_randomforest
    },

    'decisiontree_cls': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'max_depth', 'max_features', 'criterion', 'splitter'),
            'default_values': (None, 0.1, None, None, 'gini', 'best'),
            'types': (str, float, int, (int, float, str), str, str)
        },
        'type': 'cls',
        'function': train_decisiontree
    },

    'mpl_cls': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'hidden_layer_sizes', 'max_iter', 'activation', 'solver',
                     'learning_rate', 'learning_rate_init', 'tol'),
            'default_values': (None, 0.1, (100,), 200, 'relu', 'adam',
                               'constant', 0.001, 0.0001),
            'types': (str, float, list, int, str, str,
                      str, float, float)
        },
        'type': 'cls',
        'function': train_mpl
    },

    'knn_reg': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'n_neighbors', 'weights', 'algorithm'),
            'default_values': (None, 0.1, 5, 'uniform', 'auto'),
            'types': (str, float, int, str, str)
        },
        'type': 'reg',
        'function': train_knn
    },

    'randomforest_reg': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'n_estimators', 'max_depth', 'max_features', 'criterion', 'bootstrap',
                     'ccp_alpha'),
            'default_values': (None, 0.1, 100, None, "auto", "mse", True,
                               0.0),
            'types': (str, float, int, int, (int, float, str), str, bool,
                      str, float)
        },
        'type': 'reg',
        'function': train_randomforest
    },

    'decisiontree_reg': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'max_depth', 'max_features', 'criterion', 'splitter'),
            'default_values': (None, 0.1, None, None, 'mse', 'best'),
            'types': (str, float, int, (int, float, str), str, str)
        },
        'type': 'reg',
        'function': train_decisiontree
    },

    'mpl_reg': {
        'mandatory': {
            'args': ('to_drop', 'y_col'),
            'types': [list, str]
        },
        'optional': {
            'args': ('normalization_method', 'test_size', 'hidden_layer_sizes', 'max_iter', 'activation', 'solver',
                     'learning_rate', 'learning_rate_init', 'tol'),
            'default_values': (None, 0.1, (100,), 200, 'relu', 'adam',
                               'constant', 0.001, 0.0001),
            'types': (str, float, list, int, str, str,
                      str, float, float)
        },
        'type': 'reg',
        'function': train_mpl
    },

    'kmeans': {
        'mandatory': {
            'args': ('to_drop',),
            'types': [list,]
        },
        'optional': {
            'args': ('y_col', 'normalization_method', 'n_clusters', 'max_iter', 'tol', 'algorithm'),
            'default_values': (None, None, 8, 300, 0.0001, 'auto'),
            'types': (str, str, int, int, float, str)
        },
        'function': train_kmeans
    },

}


def get_columns(filename, file_extension):
    if file_extension in file_extensions['csv']:
        df = pd.read_csv(filename)
    elif file_extension in file_extensions['json']:
        df = pd.read_json(filename, orient='split')
    elif file_extension in file_extensions['excel']:
        excel = pd.ExcelFile(filename)
        df = pd.read_excel(filename, excel.sheet_names[0])
    else:
        return []
    columns = []
    for column in df:
        columns.append({
            'name': column,
            'type': df[column].dtype.__str__(),
            'null_count': int(df[column].isnull().sum())
        })
    return columns
