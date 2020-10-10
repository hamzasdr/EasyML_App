from enum import Enum


class FileType(Enum):
    CSV = 'Comma-separated Vector'
    EXCEL = 'Excel/OpenDocument Spreadsheet'
    JSON = 'Javascript Object Notation'
    SQL = 'Structured Query Language'

    @classmethod
    def choices(cls):
        return tuple((i.name.lower(), i.value) for i in cls)


class ModelType(Enum):
    NEURAL = 'Neural network'
    LINEARREG = 'Linear Regression'

    RANDOMFOREST_CLS = 'Random Forest Classifier'
    DECISIONTREE_CLS = 'Decision Tree Classifier'
    KNN_CLS = 'K-Nearest Neighbors Classifier'
    MPL_CLS = 'Multi-layer Perceptron Classifier'

    RANDOMFOREST_REG = 'Random Forest Regressor'
    DECISIONTREE_REG = 'Decision Tree Regressor'
    KNN_REG = 'K-Nearest Neighbors Regressor'
    MPL_REG = 'Multi-layer Perceptron Regressor'

    KMEANS = 'K means'

    @classmethod
    def choices(cls):
        return tuple((i.name.lower(), i.value) for i in cls)


class DeviceType(Enum):
    ANDROID = 'Android'
    IOS = 'iOS'

    @classmethod
    def choices(cls):
        return tuple((i.name.lower(), i.value) for i in cls)

    @classmethod
    def choices_list(cls):
        return [i.name.lower() for i in cls]


class LayerType(Enum):
    DENSE = 'Dense'
    Conv = 'Convolutional'

    @classmethod
    def choices(cls):
        return tuple((i.name.lower(), i.value) for i in cls)
